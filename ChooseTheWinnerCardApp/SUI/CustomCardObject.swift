//
//  RealmService.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import Foundation
import RealmSwift

// Объект Realm для кастомной карточки
class CustomCardObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var imageName: String? // Имя файла изображения, сохраненного локально
    @Persisted var imageData: Data?   // Сами данные изображения (опционально, если храним файлы отдельно)
    @Persisted var sortOrder: Int = 0 // Для сохранения порядка карточек в теме

    // Связь "родитель" с CustomThemeObject
    @Persisted(originProperty: "cards") var theme: LinkingObjects<CustomThemeObject>
}

// Объект Realm для кастомной темы
class CustomThemeObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var numberOfCards: Int = 4 // 4 or 8
    @Persisted var createdAt: Date = Date()
    @Persisted var cards = List<CustomCardObject>() // Список карточек в этой теме

    // Для удобства конвертации в GameTheme (не хранится в Realm)
    var gameTheme: GameTheme {
        // Иконку для кастомных тем можно сделать общей или генерировать
        GameTheme(title: self.title, iconName: "icon_custom_theme_placeholder") // Замените плейсхолдер
    }
}

import Foundation
import RealmSwift

class RealmService: ObservableObject {
    private let realm: Realm // Realm теперь неопциональный

    init() {
        do {
            // Для разработки может быть полезна опция удаления Realm при необходимости миграции.
            // В продакшене вам нужно будет управлять миграциями Realm.
            // let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            // self.realm = try Realm(configuration: config)
            
            // Стандартная инициализация Realm
            self.realm = try Realm()
            print("Realm initialized successfully. Path: \(realm.configuration.fileURL?.absoluteString ?? "N/A")")
        } catch {
            // Если Realm не может быть инициализирован, это критическая ошибка для работы с данными.
            // fatalError остановит приложение и выведет сообщение.
            fatalError("Error initializing Realm: \(error.localizedDescription)")
        }
    }

    // MARK: - Custom Theme Operations

    func saveNewTheme(title: String, numberOfCards: Int, cardData: [(title: String, imageData: Data?)]) {
        let newTheme = CustomThemeObject()
        newTheme.title = title
        newTheme.numberOfCards = numberOfCards
        newTheme.createdAt = Date() // Устанавливаем дату создания

        let cardObjects = cardData.enumerated().map { (index, data) -> CustomCardObject in
            let card = CustomCardObject()
            card.title = data.title
            card.imageData = data.imageData // Сохраняем данные изображения
            card.sortOrder = index
            return card
        }
        newTheme.cards.append(objectsIn: cardObjects)

        do {
            try realm.write {
                realm.add(newTheme)
            }
            print("Theme '\(newTheme.title)' saved successfully with \(newTheme.cards.count) cards.")
            objectWillChange.send() // Уведомляем UI об изменениях
        } catch {
            print("Error saving new theme to Realm: \(error.localizedDescription)")
        }
    }
    
    func updateTheme(themeId: ObjectId, newTitle: String, newNumberOfCards: Int, newCardData: [(cardIdToMatch: ObjectId?, title: String, imageData: Data?)]) {
        guard let themeToUpdate = realm.object(ofType: CustomThemeObject.self, forPrimaryKey: themeId) else {
            print("Theme with ID \(themeId) not found for update.")
            return
        }

        do {
            try realm.write {
                themeToUpdate.title = newTitle
                themeToUpdate.numberOfCards = newNumberOfCards
                
                // Стратегия обновления карточек:
                // 1. Создаем словарь существующих карточек для быстрого доступа.
                var existingCardsMap = [ObjectId: CustomCardObject]()
                for card in themeToUpdate.cards {
                    existingCardsMap[card.id] = card
                }
                
                // 2. Создаем новый список карточек для темы.
                let updatedCardObjects = List<CustomCardObject>()
                var cardsToDelete = Set(existingCardsMap.keys) // ID карт, которые нужно будет удалить

                for (index, data) in newCardData.enumerated() {
                    var cardToUpdateOrAdd: CustomCardObject
                    
                    // Пытаемся найти существующую карту по cardIdToMatch (если оно есть)
                    if let idToMatch = data.cardIdToMatch, let existingCard = existingCardsMap[idToMatch] {
                        cardToUpdateOrAdd = existingCard
                        cardsToDelete.remove(idToMatch) // Эту карту не удаляем, а обновляем
                    } else {
                        // Если ID не совпало или не было предоставлено, создаем новую карту
                        cardToUpdateOrAdd = CustomCardObject()
                        // realm.add(cardToUpdateOrAdd) // Добавляем в Realm, если она новая (но она добавится через список темы)
                    }
                    
                    cardToUpdateOrAdd.title = data.title
                    cardToUpdateOrAdd.imageData = data.imageData
                    cardToUpdateOrAdd.sortOrder = index
                    updatedCardObjects.append(cardToUpdateOrAdd)
                }
                
                // 3. Удаляем карточки, которые не были включены в newCardData
                for idToDelete in cardsToDelete {
                    if let cardObjectToDelete = existingCardsMap[idToDelete] {
                        realm.delete(cardObjectToDelete)
                    }
                }
                
                // 4. Заменяем старый список карточек новым.
                themeToUpdate.cards.removeAll() // Очищаем старый список (связи)
                themeToUpdate.cards.append(objectsIn: updatedCardObjects) // Добавляем новые/обновленные

                print("Theme '\(themeToUpdate.title)' updated successfully. New card count: \(themeToUpdate.cards.count)")
            }
            objectWillChange.send()
        } catch {
            print("Error updating theme in Realm: \(error.localizedDescription)")
        }
    }

    func fetchCustomThemes() -> Results<CustomThemeObject> {
        // Загружаем все CustomThemeObject, отсортированные по дате создания (новые сверху)
        return realm.objects(CustomThemeObject.self).sorted(byKeyPath: "createdAt", ascending: false)
    }

    func deleteTheme(withId themeId: ObjectId) {
        guard let themeToDelete = realm.object(ofType: CustomThemeObject.self, forPrimaryKey: themeId) else {
            print("Theme with ID \(themeId) not found for deletion.")
            return
        }
        
        do {
            try realm.write {
                // Сначала удаляем все связанные карточки этой темы
                realm.delete(themeToDelete.cards)
                // Затем удаляем саму тему
                realm.delete(themeToDelete)
            }
            print("Theme with ID '\(themeId)' and its cards deleted successfully.")
            objectWillChange.send()
        } catch {
            print("Error deleting theme from Realm: \(error.localizedDescription)")
        }
    }

    // Вспомогательная функция для получения темы по ID (может пригодиться)
    func getTheme(withId themeId: ObjectId) -> CustomThemeObject? {
        return realm.object(ofType: CustomThemeObject.self, forPrimaryKey: themeId)
    }
}
