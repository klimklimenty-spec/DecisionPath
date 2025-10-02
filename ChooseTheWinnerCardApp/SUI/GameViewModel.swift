import SwiftUI
import Combine

class GameViewModel: ObservableObject, Identifiable {
    let id = UUID() // Для Identifiable, чтобы использовать с .sheet(item: ...)
    @Published var theme: GameTheme
    @Published var currentPair: GamePair? = nil
    @Published var finalWinner: CardItem? = nil
    @Published var showResults: Bool = false
    @Published var gameProgressText: String = ""

    @Published var allCardsForTheme: [CardItem] = [] // Исходные карты для первого столбца сетки
    @Published var playedRounds: [[CardItem]] = []    // Победители каждого раунда матчей
    @Published var matchDetails: [UUID: (challenger1: CardItem, challenger2: CardItem)] = [:] // Детали матчей

    private var contenders: [CardItem] = [] // Карточки, играющие в текущем раунде
    private var currentRoundWinners: [CardItem] = [] // Победители, собранные в текущем раунде
    
    private var initialCardCount: Int = 0
    private var currentRoundNumber: Int = 1 // Номер текущего раунда матчей (1-индексированный)
    private var totalRoundsToPlay: Int = 0  // Общее количество раундов до определения победителя
    private var matchesPlayedInCurrentFullRound: Int = 0 // Счетчик матчей для отображения прогресса

    init(theme: GameTheme, mockCards: [CardItem]) {
        self.theme = theme
        self.allCardsForTheme = mockCards // Не перемешиваем, сохраняем порядок для сетки
        self.initialCardCount = self.allCardsForTheme.count
        if initialCardCount > 0 {
            // totalRoundsToPlay - это количество раундов матчей,
            // т.е. если 8 карт, то 3 раунда матчей (8->4, 4->2, 2->1)
            self.totalRoundsToPlay = Int(ceil(log2(Double(initialCardCount))))
            // Если initialCardCount = 1, log2(1) = 0. Это нормально, игры не будет.
            // Если initialCardCount = 0, log2(0) не определен, поэтому проверка > 0.
        } else {
            self.totalRoundsToPlay = 0
        }
        print("GameViewModel INIT: Theme - \(theme.title), Cards count - \(mockCards.count), Total rounds to play - \(totalRoundsToPlay)")
        startGame()
    }

    func startGame() {
        contenders = allCardsForTheme.shuffled() // Перемешиваем для случайных пар в игре
        currentRoundWinners = []
        playedRounds = []
        matchDetails = [:]
        finalWinner = nil
        showResults = false
        currentRoundNumber = 1
        matchesPlayedInCurrentFullRound = 0
        
        // Если карт 0 или 1, игра сразу завершается
        if initialCardCount <= 1 {
            finalWinner = allCardsForTheme.first
            if finalWinner != nil {
                 playedRounds.append([finalWinner!]) // Чтобы победитель был в сетке
            }
            showResults = true
            updateProgressText()
        } else {
            loadNextPair()
        }
    }

    func loadNextPair() {
        updateProgressText()
        print("LOAD NEXT PAIR: Round \(currentRoundNumber). Contenders: \(contenders.count) (\(contenders.map { $0.name })), CurrentRoundWinners: \(currentRoundWinners.count)")
        
        if contenders.count >= 2 {
            let c1 = contenders.removeFirst()
            let c2 = contenders.removeFirst()
            currentPair = GamePair(card1: c1, card2: c2)
            matchesPlayedInCurrentFullRound += 1
            print("GameViewModel LOAD NEXT PAIR: New pair loaded - \(currentPair!.card1.name) vs \(currentPair!.card2.name)")
        } else {
            // Недостаточно карт в contenders для новой пары, значит текущий раунд завершен или нужно обработать "bye"
            startNextRoundOrFinishGame()
        }
    }

    private func startNextRoundOrFinishGame() {
        currentPair = nil // Очищаем текущую пару

        // Если в `contenders` осталась одна карта, это "bye", она автоматически проходит в следующий раунд
        if let byeCard = contenders.first, contenders.count == 1 {
            currentRoundWinners.append(byeCard)
            contenders.removeAll()
            print("BYE CARD: \(byeCard.name) moves to winners of round \(currentRoundNumber)")
        }

        // Если были сыграны матчи или были "bye", сохраняем победителей этого раунда
        if !currentRoundWinners.isEmpty {
            // Только если этот список победителей еще не был добавлен (избегаем дублирования при "bye")
             if playedRounds.last != currentRoundWinners { // Простая проверка, может потребовать более надежной
                playedRounds.append(currentRoundWinners)
                print("ROUND \(currentRoundNumber) COMPLETED. Winners: \(currentRoundWinners.map { $0.name })")
             }
        }

        // Проверяем, определен ли финальный победитель
        if currentRoundWinners.count == 1 && currentRoundNumber >= totalRoundsToPlay {
            finalWinner = currentRoundWinners.first
            showResults = true
            updateProgressText()
            print("GAME FINISHED: Winner - \(finalWinner?.name ?? "N/A")")
            return
        }
        
        // Если победителей нет (например, стартовали с 0 карт) или все раунды сыграны
        if currentRoundWinners.isEmpty && contenders.isEmpty && (playedRounds.isEmpty || currentRoundNumber >= totalRoundsToPlay) {
             if initialCardCount > 0 && finalWinner == nil { // Если игра была, но победитель не определился (редкий случай)
                print("Game ended inconclusively, attempting to find a winner from last round winners if any.")
                finalWinner = playedRounds.last?.first // Попытка
             }
             showResults = true
             updateProgressText()
             print("GAME ENDED (no more contenders/winners or all rounds played). Final winner: \(finalWinner?.name ?? "N/A")")
             return
        }


        // Готовимся к следующему раунду
        currentRoundNumber += 1
        contenders = currentRoundWinners.shuffled() // Победители предыдущего раунда становятся участниками нового
        currentRoundWinners = []
        matchesPlayedInCurrentFullRound = 0

        if contenders.count < 2 && !contenders.isEmpty { // Если в новый раунд прошла только одна карта (уже победитель)
             finalWinner = contenders.first
             if finalWinner != nil && (playedRounds.isEmpty || playedRounds.last?.first?.id != finalWinner!.id) {
                 playedRounds.append([finalWinner!])
             }
             showResults = true
             updateProgressText()
             print("GAME FINISHED (single contender for new round): Winner - \(finalWinner?.name ?? "N/A")")
        } else if contenders.count < 2 && contenders.isEmpty { // Если в новый раунд не прошел никто (игра должна была закончиться)
            print("Error: No contenders for the new round, but game not finished.")
            showResults = true // Показываем что есть
            updateProgressText()
        }
        else {
            print("STARTING NEXT ROUND \(currentRoundNumber): Contenders - \(contenders.map { $0.name })")
            loadNextPair()
        }
    }

    func cardSelected(_ selectedCard: CardItem) {
        guard let pair = currentPair else {
            print("Error: Card selected but no current pair.")
            return
        }
        
        let loserCard = (selectedCard.id == pair.card1.id) ? pair.card2 : pair.card1
        currentRoundWinners.append(selectedCard)

        matchDetails[selectedCard.id] = (challenger1: pair.card1, challenger2: pair.card2)
        
        print("CARD SELECTED: \(selectedCard.name) wins against \(loserCard.name). Round \(currentRoundNumber) winners so far: \(currentRoundWinners.map{$0.name})")
        
        currentPair = nil // Очищаем пару для анимации исчезновения в UI

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { // Задержка перед следующей парой
            self.loadNextPair()
        }
    }

    private func updateProgressText() {
        if showResults {
            if finalWinner != nil {
                gameProgressText = "Winner!"
            } else if initialCardCount > 0 {
                 gameProgressText = "Results"
            } else {
                gameProgressText = "No Game"
            }
            return
        }
        if initialCardCount == 0 {
            gameProgressText = "No cards"
            return
        }
        
        // Примерный подсчет карт, оставшихся в "пуле" для текущего раунда
        // (contenders + currentRoundWinners + (currentPair != nil ? 2 : 0))
        // Это количество должно уменьшаться вдвое каждый раунд.
        // Начальное количество карт для этого раунда = initialCardCount / 2^(currentRoundNumber-1)
        let cardsExpectedAtStartOfThisRound = Double(initialCardCount) / pow(2.0, Double(currentRoundNumber - 1))
        
        if cardsExpectedAtStartOfThisRound >= 2 {
             gameProgressText = "Round of \(Int(round(cardsExpectedAtStartOfThisRound)))"
        } else if cardsExpectedAtStartOfThisRound >= 1 && totalRoundsToPlay == currentRoundNumber {
             gameProgressText = "Final Round!"
        } else if initialCardCount == 1 {
             gameProgressText = "The One!" // Если начали с 1 карты
        }
        else {
             gameProgressText = "Round \(currentRoundNumber)"
        }
    }
    
    func resetGame() {
        // Для корректного сброса, нам нужно знать исходные mockCards,
        // так как allCardsForTheme мог быть изменен (хотя в текущей логике он не должен меняться после init)
        // Простой вариант: заново инициализировать с теми же параметрами.
        // Для этого GameThemesView должен будет пересоздать GameViewModel.
        // Здесь просто вызываем startGame, предполагая, что allCardsForTheme не изменился критично.
        
        // Восстанавливаем allCardsForTheme из какого-то источника, если он мог измениться.
        // Если он не меняется, то просто:
        // self.allCardsForTheme = self.allCardsForTheme (не нужно)
        // Но если он мог быть отфильтрован или изменен, то нужен источник.
        
        // Предположим, allCardsForTheme - это константа для данной игры после init.
        print("RESET GAME CALLED")
        if !self.allCardsForTheme.isEmpty {
             self.initialCardCount = self.allCardsForTheme.count
             if initialCardCount > 0 {
                 self.totalRoundsToPlay = Int(ceil(log2(Double(initialCardCount))))
             } else {
                 self.totalRoundsToPlay = 0
             }
             startGame()
        } else {
            print("Cannot reset game, allCardsForTheme is empty.")
            // Возможно, нужно полностью сбросить ViewModel или показать ошибку
            self.showResults = false // Скрыть результаты, если они были
            self.gameProgressText = "Error resetting"
        }
    }

    func wasChosen(card: CardItem) -> Bool {
        if finalWinner?.id == card.id { return true }
        if matchDetails[card.id] != nil { return true }
        for round in playedRounds {
            if round.contains(where: { $0.id == card.id }) {
                return true
            }
        }
        // Проверяем, была ли карта в исходном списке, если игра только началась и нет истории матчей
        if playedRounds.isEmpty && matchDetails.isEmpty {
            return allCardsForTheme.contains(where: {$0.id == card.id}) && initialCardCount <= 2 // Для игр из 1-2 карт
        }
        return false
    }
}
