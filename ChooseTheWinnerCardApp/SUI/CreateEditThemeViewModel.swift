//
//  CreateEditThemeView.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI
import Combine // Для ObservableObject и @Published
import PhotosUI // Для PhotoPicker
import RealmSwift // Для ObjectId

@available(iOS 16.0, *)
class CreateEditThemeViewModel: ObservableObject {
    // Зависимости
    private var realmService: RealmService
    
    // Редактируемая тема (nil если создаем новую)
    private var themeToEdit: CustomThemeObject?
    var isEditing: Bool { themeToEdit != nil }

    // Состояние формы
    @Published var themeTitle: String = ""
    @Published var numberOfCards: Int = 4 { // 4 или 8
        didSet {
            // При изменении количества карт, обновляем массив cardData
            adjustCardDataArray()
            validateForm()
        }
    }
    @Published var cardData: [CardInputData] = [] // Данные для каждой карточки

    // Состояние для PhotoPicker
    @Published var selectedPhotoPickerItem: PhotosPickerItem? = nil {
        didSet {
            if let selectedItem = selectedPhotoPickerItem, let targetCardIndex = photoPickerTargetIndex {
                processSelectedPhoto(item: selectedItem, forCardIndex: targetCardIndex)
            }
        }
    }
    @Published var photoPickerTargetIndex: Int? = nil // Индекс карточки, для которой выбирается фото

    // Валидация и состояние кнопки Save
    @Published var canSave: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    init(realmService: RealmService, themeToEdit: CustomThemeObject? = nil) {
        self.realmService = realmService
        self.themeToEdit = themeToEdit

        if let theme = themeToEdit {
            // Заполняем форму данными редактируемой темы
            self.themeTitle = theme.title
            self.numberOfCards = theme.numberOfCards
            self.cardData = theme.cards.sorted(by: { $0.sortOrder < $1.sortOrder }).map { cardObject in
                CardInputData(
                    id: cardObject.id, // Сохраняем ID для обновления
                    title: cardObject.title,
                    imageData: cardObject.imageData,
                    uiImage: cardObject.imageData != nil ? UIImage(data: cardObject.imageData!) : nil
                )
            }
        } else {
            // Инициализируем для новой темы
            adjustCardDataArray()
        }
        
        // Подписываемся на изменения для валидации
        Publishers.CombineLatest3($themeTitle, $numberOfCards, $cardData)
            .map { [weak self] title, numCards, cards -> Bool in
                guard let self = self else { return false }
                return self.isFormValid(title: title, numCards: numCards, cards: cards)
            }
            .assign(to: \.canSave, on: self)
            .store(in: &cancellables)
    }

    private func adjustCardDataArray() {
        let currentCount = cardData.count
        if numberOfCards > currentCount {
            // Добавляем недостающие пустые ячейки
            for _ in currentCount..<numberOfCards {
                cardData.append(CardInputData())
            }
        } else if numberOfCards < currentCount {
            // Удаляем лишние ячейки с конца
            cardData.removeLast(currentCount - numberOfCards)
        }
    }

    private func isFormValid(title: String, numCards: Int, cards: [CardInputData]) -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // errorMessage = "Theme title cannot be empty." // Можно показывать ошибки
            return false
        }
        guard cards.count == numCards else { // Убедимся, что количество ячеек соответствует выбору
            // errorMessage = "Card data mismatch."
            return false
        }
        // Все карточки должны иметь название
        let allCardsHaveTitles = cards.allSatisfy { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if !allCardsHaveTitles {
            // errorMessage = "All cards must have a title."
            return false
        }
        // errorMessage = nil
        return true
    }
    
    func validateForm() { // Публичный метод для вызова из View, если нужно
        self.canSave = isFormValid(title: themeTitle, numCards: numberOfCards, cards: cardData)
    }

    private func processSelectedPhoto(item: PhotosPickerItem, forCardIndex index: Int) {
        guard index < cardData.count else { return }
        
        Task { @MainActor in // Выполняем в MainActor для обновления UI
            do {
                if let imageData = try await item.loadTransferable(type: Data.self) {
                    self.cardData[index].imageData = imageData
                    self.cardData[index].uiImage = UIImage(data: imageData)
                    self.selectedPhotoPickerItem = nil // Сбрасываем, чтобы позволить повторный выбор того же фото
                    self.photoPickerTargetIndex = nil
                    self.validateForm() // Перепроверяем форму, хотя фото не влияет на canSave напрямую
                } else {
                    print("Could not load image data.")
                    // Показать ошибку пользователю
                }
            } catch {
                print("Error loading image: \(error)")
                // Показать ошибку пользователю
            }
        }
    }
    
    func clearImage(forCardIndex index: Int) {
        guard index < cardData.count else { return }
        cardData[index].imageData = nil
        cardData[index].uiImage = nil
        validateForm()
    }

    func saveTheme() {
        guard canSave else {
            print("Form is not valid, cannot save.")
            return
        }

        let cardsToSave = cardData.map { (title: $0.title, imageData: $0.imageData) }

        if let theme = themeToEdit {
            // Редактирование существующей темы
            let cardDataForUpdate = cardData.map {
                (cardIdToMatch: $0.id, title: $0.title, imageData: $0.imageData)
            }
            realmService.updateTheme(
                themeId: theme.id,
                newTitle: themeTitle,
                newNumberOfCards: numberOfCards,
                newCardData: cardDataForUpdate
            )
        } else {
            // Сохранение новой темы
            realmService.saveNewTheme(
                title: themeTitle,
                numberOfCards: numberOfCards,
                cardData: cardsToSave
            )
        }
    }
}

// Вспомогательная структура для управления данными карточки в UI
struct CardInputData: Identifiable, Equatable {
    let id: ObjectId? // ObjectId существующей карты (для редактирования) или nil для новой
    var title: String = ""
    var imageData: Data? = nil // Данные для сохранения в Realm
    var uiImage: UIImage? = nil // Для отображения в UI (не сохраняется напрямую, если imageData есть)
    
    // Генерируем временный UUID для Identifiable в ForEach, если id из Realm nil
    private let localId = UUID()
    var viewId: UUID { localId }

    init(id: ObjectId? = nil, title: String = "", imageData: Data? = nil, uiImage: UIImage? = nil) {
        self.id = id
        self.title = title
        self.imageData = imageData
        self.uiImage = uiImage
    }
    
    // Equatable нужен для Combine $cardData.
    // Сравниваем только по viewId, так как содержимое может меняться,
    // но для Combine важно, изменился ли сам набор элементов массива.
    static func == (lhs: CardInputData, rhs: CardInputData) -> Bool {
        lhs.viewId == rhs.viewId && lhs.title == rhs.title && lhs.imageData == rhs.imageData
    }
}
