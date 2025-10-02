//
//  AICardGeneratorViewModel.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI
import Combine

@MainActor // Гарантирует, что @Published свойства обновляются в главном потоке
class AICardGeneratorViewModel: ObservableObject {
    @Published var userPrompt: String = ""
    @Published var numberOfCards: Int = 8 // По умолчанию 8, можно 4
    @Published var isLoading: Bool = false
    @Published var generatedCardItems: [CardItem]? = nil
    @Published var errorMessage: String? = nil
    @Published var showGamePlayView: Bool = false // Для навигации к игре

    private let geminiService = GeminiService() // Экземпляр нашего сервиса
    var gameViewModelForAIGame: GameViewModel? = nil // Для передачи в GamePlayView

    var canGenerate: Bool {
        !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    func generateAndPlay() {
        guard canGenerate else { return }

        isLoading = true
        errorMessage = nil
        generatedCardItems = nil
        gameViewModelForAIGame = nil

        Task {
            let result = await geminiService.generateCardTitles(prompt: userPrompt, count: numberOfCards)
            isLoading = false

            switch result {
            case .success(let titles):
                if titles.count == numberOfCards {
                    self.generatedCardItems = titles.map { CardItem(name: $0, imageData: nil) } // imageData: nil, так как AI не генерирует картинки
                    
                    // Подготовка к запуску игры
                    let aiTheme = GameTheme(title: "AI: \(userPrompt.prefix(20))...", iconName: "icon_ai_theme_placeholder") // Плейсхолдер иконка
                    if let items = self.generatedCardItems {
                        self.gameViewModelForAIGame = GameViewModel(theme: aiTheme, mockCards: items)
                        self.showGamePlayView = true // Сигнал для View открыть игру
                    } else {
                        self.errorMessage = "Failed to prepare AI generated cards for the game."
                    }
                    print("AI Generated Titles: \(titles)")
                } else {
                    self.errorMessage = "AI generated \(titles.count) items, but \(numberOfCards) were expected. Please try a different prompt or count."
                    print("Error: AI returned \(titles.count) titles, expected \(numberOfCards)")
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("AI Generation Error: \(error.localizedDescription)")
            }
        }
    }
}
