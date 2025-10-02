//
//  Achievement.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI

// Уникальный идентификатор для каждого типа достижения
enum AchievementType: String, CaseIterable, Codable {
    case firstPick
    case decisionMaker
    case serialPicker
    case theCreator
    case masterBuilder
    case aiPioneer
    case techEnthusiast
    case themeExplorer
    case collector
    case prizerGrandmaster
    
    // Свойства для отображения
    var title: String {
        switch self {
        case .firstPick: return "First Pick!"
        case .decisionMaker: return "Decision Maker"
        case .serialPicker: return "Serial Picker"
        case .theCreator: return "The Creator"
        case .masterBuilder: return "Master Builder"
        case .aiPioneer: return "AI Pioneer"
        case .techEnthusiast: return "Tech Enthusiast"
        case .themeExplorer: return "Theme Explorer"
        case .collector: return "Collector"
        case .prizerGrandmaster: return "Prizer Grandmaster"
        }
    }
    
    var description: String {
        switch self {
        case .firstPick: return "You've made your first choice. Welcome to the game!"
        case .decisionMaker: return "Completed 20 games. You know what you like!"
        case .serialPicker: return "Completed 50 games. A true connoisseur!"
        case .theCreator: return "Created your very first custom picker."
        case .masterBuilder: return "Created 15 custom pickers. Your world, your rules!"
        case .aiPioneer: return "Generated your first game using AI. The future is now!"
        case .techEnthusiast: return "Generated 15 games using AI. You and AI make a great team!"
        case .themeExplorer: return "Played all pre-defined themes at least once."
        case .collector: return "You've seen and picked from 100 different cards across all games."
        case .prizerGrandmaster: return "Unlocked all other achievements. You are a legend!"
        }
    }
    
    // Иконка для заблокированного и разблокированного состояния
    var lockedIconName: String { "achievement_lock_icon" } // Ваше имя ассета для замка
    var unlockedIconName: String { "achievement_star_icon" } // Ваше имя ассета для звезды
}

struct Achievement: Identifiable {
    let id: AchievementType // Используем Enum как ID
    var type: AchievementType { id } // Для удобства доступа
    var isUnlocked: Bool
    
    // Для использования в SwiftUI ForEach, если id не строка
    // var listId: String { id.rawValue }
}
