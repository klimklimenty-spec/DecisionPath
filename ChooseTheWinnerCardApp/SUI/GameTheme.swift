//
//  Model.swift
//  PP
//
//  Created by D K on 12.05.2025.
//

import SwiftUI

// Модель для представления темы игры
struct GameTheme: Identifiable, Hashable {
    let id = UUID()
    var title: String // Сделал var, если вдруг понадобится менять для AI тем
    var iconName: String
}

// В Models.swift
struct CardItem: Identifiable, Hashable, Equatable {
    var id = UUID()
    var name: String
    var imageName: String? // Для Assets
    var imageData: Data?   // Для изображений из Realm
    // ... (static func == и hash(into:))

    // Конструктор для Assets
    init(id: UUID = UUID(), name: String, imageName: String) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.imageData = nil
    }

    // Конструктор для Data из Realm
    init(id: UUID = UUID(), name: String, imageData: Data?) {
        self.id = id
        self.name = name
        self.imageName = nil
        self.imageData = imageData
    }
    
    // Общий конструктор, если нужно (хотя два специфичных могут быть лучше)
    init(id: UUID = UUID(), name: String, imageName: String? = nil, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.imageData = imageData
    }
}

// Структура для пары карточек в игре (сделана Equatable для .onChange)
struct GamePair: Equatable {
    let card1: CardItem
    let card2: CardItem

    static func == (lhs: GamePair, rhs: GamePair) -> Bool {
        return lhs.card1.id == rhs.card1.id && lhs.card2.id == rhs.card2.id
    }
}


// Примерные цвета (можете вынести в отдельный файл или расширение Color)
extension Color {
    static let deepPurple = Color(hex: "01182F")
    static let neonGreen = Color(red: 57/255, green: 255/255, blue: 20/255)
    static let lightGreen = Color(red: 150/255, green: 255/255, blue: 150/255)
    static let buttonTextYellow = Color(red: 255/255, green: 190/255, blue: 0/255)
}

//// Пример мокаповых данных (перенесите или создайте свой файл Data.swift)
//// Вам нужно будет определить predefinedThemes и мокапы карточек для каждой темы
//// Например:
//let predefinedThemes: [GameTheme] = [
//    GameTheme(title: "NBA Legends", iconName: "icon_basketball_neutral"),
//    GameTheme(title: "Football Strikers Greats", iconName: "icon_soccer_neutral"),
//    GameTheme(title: "Tennis Champions", iconName: "icon_tennis_neutral"),
//    GameTheme(title: "Iconic Sports Gear", iconName: "icon_gear_neutral"),
//    GameTheme(title: "Legendary F1 Drivers", iconName: "icon_f1_neutral"),
//]
//
//let mockNBALegendsCards: [CardItem] = [
//    CardItem(name: "LeBron James", imageName: "neutral_basketball_1"),
//    CardItem(name: "Michael Jordan", imageName: "neutral_basketball_1"),
//    CardItem(name: "Kobe Bryant", imageName: "neutral_basketball_1"),
//    CardItem(name: "Magic Johnson", imageName: "neutral_basketball_1")
//]
//// ... и другие мокапы ...
//let mockSportsGear: [CardItem] = [ // Пример для темы "Iconic Sports Gear"
//    CardItem(name: "Air Jordans", imageName: "neutral_basketball_1"),
//    CardItem(name: "Stan Smith", imageName: "neutral_basketball_1"),
//    CardItem(name: "Wilson Racket", imageName: "neutral_basketball_1"),
//    CardItem(name: "Spalding Ball", imageName: "neutral_basketball_1"),
//    CardItem(name: "1Air Jordans", imageName: "neutral_basketball_1"),
//    CardItem(name: "1Stan Smith", imageName: "neutral_basketball_1"),
//    CardItem(name: "1Wilson Racket", imageName: "neutral_basketball_1"),
//    CardItem(name: "1Spalding Ball", imageName: "neutral_basketball_1")
//]
//
//let mockBasketballHeroes: [CardItem] = [
//    CardItem(name: "Hero Dunker", imageName: "neutral_basketball_1"), // Замените imageName
//    CardItem(name: "Speedy Guard", imageName: "neutral_basketball_2"),
//    CardItem(name: "Tall Center", imageName: "neutral_basketball_1"),
//    CardItem(name: "Sharp Shooter", imageName: "neutral_basketball_1")    // Добавьте до 4 или 8
//]


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6: // RGB (без альфы)
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        case 8: // RGBA
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        default:
            r = 1.0
            g = 1.0
            b = 1.0
            a = 1.0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
