//
//  AchievementsService.swift
//  PP
//
//  Created by D K on 14.05.2025.
//
import SwiftUI
import Combine

class AchievementsService: ObservableObject {
    @Published private(set) var achievements: [Achievement] = []
    // newlyUnlockedAchievement больше не нужен здесь для автоматического показа алерта
    // @Published var newlyUnlockedAchievement: Achievement? = nil
    
    private let userDefaultsKeyPrefix = "prizer_achievement_"

    init() {
        // Загружаем и строим список при инициализации
        // чтобы achievements были актуальны для AchievementsListView
        refreshAchievementsStatus()
        print("AchievementsService initialized. Current status loaded.")
    }

    private func userDefaultsKey(for type: AchievementType) -> String {
        return "\(userDefaultsKeyPrefix)\(type.rawValue)_unlocked"
    }

    // Этот метод обновляет состояние достижений в сервисе на основе UserDefaults
    // Его нужно будет вызывать из AchievementsListView в onAppear
    func refreshAchievementsStatus() {
        var updatedAchievements: [Achievement] = []
        for type in AchievementType.allCases {
            let isUnlocked = UserDefaults.standard.bool(forKey: userDefaultsKey(for: type))
            updatedAchievements.append(Achievement(id: type, isUnlocked: isUnlocked))
        }
        // Сортировка, если AchievementType.allCases не гарантирует порядок
        // updatedAchievements.sort { $0.id.rawValue < $1.id.rawValue }
        
        // Проверяем, изменился ли фактически список, чтобы избежать лишних обновлений UI
        if self.achievements.count != updatedAchievements.count ||
           !self.achievements.elementsEqual(updatedAchievements, by: { $0.id == $1.id && $0.isUnlocked == $1.isUnlocked }) {
            self.achievements = updatedAchievements
            print("Achievements status refreshed. Unlocked: \(achievements.filter{$0.isUnlocked}.map{$0.id.rawValue})")
        }
    }

    // Этот метод теперь просто сохраняет факт разблокировки в UserDefaults
    // и обновляет внутренний массив. View отвечает за то, чтобы вызвать его только один раз.
    func markAchievementAsUnlocked(_ type: AchievementType) {
        let key = userDefaultsKey(for: type)
        if !UserDefaults.standard.bool(forKey: key) { // Если еще не было помечено как разблокированное
            UserDefaults.standard.set(true, forKey: key)
            
            if let index = achievements.firstIndex(where: { $0.id == type }) {
                if !achievements[index].isUnlocked { // Дополнительная проверка, чтобы не вызывать objectWillChange зря
                    achievements[index].isUnlocked = true
                    objectWillChange.send() // Уведомить подписчиков об изменении массива
                    print("Achievement '\(type.title)' marked as unlocked and status updated.")
                }
            } else {
                // Этого не должно произойти, если buildAchievementsList вызывается правильно
                refreshAchievementsStatus() // На всякий случай перестроить, если элемента не было
            }
        }
    }
    
    // Получить конкретное достижение для показа в алерте
    func getAchievementData(for type: AchievementType) -> Achievement? {
        return achievements.first(where: { $0.id == type }) ?? Achievement(id: type, isUnlocked: UserDefaults.standard.bool(forKey: userDefaultsKey(for: type)))
    }

    // Для отладки
    #if DEBUG
    func resetSpecificAchievementForDemo(_ type: AchievementType) {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey(for: type))
        refreshAchievementsStatus() // Обновляем список
        print("Achievement reset: \(type.rawValue)")
    }
    func resetAllDemoAchievements() {
        let demoTypes: [AchievementType] = [.firstPick, .theCreator, .aiPioneer]
        for type in demoTypes {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey(for: type))
        }
        refreshAchievementsStatus()
    }
    #endif
}
