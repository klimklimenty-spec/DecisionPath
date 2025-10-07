//import SwiftUI
//
@available(iOS 16.0, *)
struct ResultPathView: View {
    @ObservedObject var viewModel: GameViewModel
    var onPlayAgain: () -> Void
    var onChooseNewTheme: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    VStack(spacing: 10) { // Уменьшил общий spacing
                        Text(viewModel.theme.title.uppercased())
                            .font(.title2.bold())
                            .foregroundColor(.buttonTextYellow)
                            .padding(.top, 10) // Добавил отступ сверху
                        
                        Text("Your Path")
                            .font(.title3.bold())
                            .foregroundColor(.neonGreen)
                        
                        if viewModel.allCardsForTheme.count == 4 {
                            ScrollView(.horizontal) {
                                PrizerBracketView4(viewModel: viewModel)
                                    .frame(width: 400, height: calculateBracketHeightFor4()) // Выделите нужную высоту
                            }
                        } else if viewModel.allCardsForTheme.count == 8 {
                            ScrollView(.horizontal) {
                                PrizerBracketView8(viewModel: viewModel)
                                    .frame(width: 500, height: calculateBracketHeightFor8())
                            }
                            .scrollIndicators(.hidden)
                        } else {
                            Text("Bracket not available for \(viewModel.allCardsForTheme.count) cards.")
                                .foregroundColor(.white)
                                .frame(minHeight: 100)
                        }
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20) // Отступы для всей плашки от краев экрана
                }
                
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        Text("Play Again")
                            .gameButtonStyle(backgroundColor: .neonGreen, textColor: .deepPurple)
                    }
                    Button(action: onChooseNewTheme) {
                        Text("Choose new theme")
                            .gameButtonStyle(backgroundColor: .deepPurple.opacity(0.9), textColor: .neonGreen, strokeColor: .neonGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 150)
            }
        }
        .scrollIndicators(.hidden)
    }
    private func calculateBracketHeightFor4() -> CGFloat {
        return 550 // Это значение нужно будет настроить!
    }
    
    private func calculateBracketHeightFor8() -> CGFloat {
        return 1050 // Заглушка, настроить когда будет сетка на 8
    }
}

struct GameButtonStyle: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    var strokeColor: Color? = nil
    
    func body(content: Content) -> some View {
        content
            .font(.headline.bold())
            .padding(.vertical, 12) // Уменьшил padding
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12) // Уменьшил радиус
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor ?? .clear, lineWidth: 1.5)
            )
            //.shadow(color: backgroundColor.opacity(0.4), radius: 4, y: 2) // Уменьшил тень
    }
}

extension View {
    func gameButtonStyle(backgroundColor: Color, textColor: Color, strokeColor: Color? = nil) -> some View {
        self.modifier(GameButtonStyle(backgroundColor: backgroundColor, textColor: textColor, strokeColor: strokeColor))
    }
}


import SwiftUI

struct BracketCardItemView: View {
    let card: CardItem // CardItem теперь может содержать imageName или imageData
    let isSelected: Bool
    let isFinalWinner: Bool

    static let cardWidth: CGFloat = 75
    static let cardHeight: CGFloat = 105

    var body: some View {
        VStack(spacing: 2) {
            // Логика отображения изображения
            if card.imageData == nil && (card.imageName == nil || card.imageName!.isEmpty) {
                // Текстовая карточк
                
                Spacer()
                Text(card.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(8) // Отступы для текста
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Занимает все место
                Spacer()

            } else {
                Group { // Используем Group для условного рендеринга внутри
                    if let imgData = card.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let imgName = card.imageName, !imgName.isEmpty {
                        Image(imgName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        // Плейсхолдер, если нет ни imageData, ни imageName
                        Rectangle()
                            .fill(Color.gray.opacity(0.2)) // Фон для плейсхолдера
                            .overlay(
                                Image(systemName: "photo") // Иконка плейсхолдера
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                }
                .frame(width: Self.cardWidth, height: Self.cardHeight * 0.75) // Изображение занимает часть высоты
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(Color.black.opacity(0.1)) // Легкий фон под изображением
                
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )

               
                
                Text(card.name)
                    .minimumScaleFactor(0.2)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 4)
                    .frame(height: Self.cardHeight * 0.25 - 4) // Оставшаяся высота для текста
            }

            
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .background(backgroundFill()) // Фон для всей карточки
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor(), lineWidth: lineWidth())
        )
        .shadow(color: shadowColor().opacity(isFinalWinner ? 0.7 : 0.5), radius: isFinalWinner ? 7 : 4, x: 0, y: 0)
    }

    private func backgroundFill() -> Color {
        if isFinalWinner {
            return Color.yellow.opacity(0.25)
        } else if isSelected {
            return Color.neonGreen.opacity(0.15)
        }
        // Для карточек, которые участвовали, но не были выбраны или не являются финальным победителем
        // Можно сделать их еще более тусклыми, если isSelected == false
        // и это не финальный победитель (т.е. проигравшая карта в паре)
        // В текущей логике сетки, isSelected = true для всех победителей раундов.
        // Для проигравших карт, которые могут быть показаны в первом раунде, isSelected будет false.
        return Color.deepPurple.opacity(isSelected ? 0.6 : 0.4)
    }

    private func strokeColor() -> Color {
        if isFinalWinner {
            return .yellow
        } else if isSelected {
            return .neonGreen
        }
        // Если карта не выбрана (например, проигравшая в первом раунде),
        // можно сделать обводку менее заметной или другого цвета.
        return Color.neonGreen.opacity(isSelected ? 0.6 : 0.3)
    }

    private func lineWidth() -> CGFloat {
        if isFinalWinner {
            return 3.0
        } else if isSelected {
            return 2.0
        }
        return 1.0
    }
    
    private func shadowColor() -> Color {
        if isFinalWinner {
            return .yellow
        } else if isSelected {
            return .neonGreen
        }
        return .black.opacity(0.4)
    }
}

struct PrizerBracketView4: View {
    @ObservedObject var viewModel: GameViewModel // ViewModel для доступа к данным

    // Карточки для сетки 4-2-1
    // Мы ожидаем, что viewModel.allCardsForTheme содержит 4 карты для этого View
    // А viewModel.playedRounds[0] содержит 2 карты (победители 1-го раунда)
    // А viewModel.finalWinner (или playedRounds[1][0]) - это финальный победитель

    // --- Configuration for Layout (как в вашем коде) ---
    let cardW = BracketCardItemView.cardWidth
    let cardH = BracketCardItemView.cardHeight
    let horizontalSpacing: CGFloat = 60 // Уменьшил немного
    let verticalSpacingInPair: CGFloat = 25
    let verticalSpacingBetweenPairs: CGFloat = 40

    // --- Calculated Positions (центры карт) ---
    // Позиции теперь относительны некоторой начальной точки (0,0) в ZStack
    // или будут использоваться с .offset() или .position() внутри родительского View.
    // Для простоты оставим ваш подход с абсолютными позициями, но их нужно будет
    // скорректировать, чтобы они хорошо смотрелись в контексте ResultPathView.
    // Сделаем их относительно верхнего левого угла области рисования.

    let col1X: CGFloat
    let col2X: CGFloat
    let col3X: CGFloat

    // Позиции Y для первой колонки (4 карты)
    let p1Y: CGFloat
    let p2Y: CGFloat
    let p3Y: CGFloat
    let p4Y: CGFloat

    // Позиции Y для второй колонки (2 карты)
    let p5Y: CGFloat
    let p6Y: CGFloat

    // Позиция Y для третьей колонки (1 карта)
    let p7Y: CGFloat

    // Карты
    var card1_col1: CardItem?
    var card2_col1: CardItem?
    var card3_col1: CardItem?
    var card4_col1: CardItem?

    var card1_col2: CardItem? // Победитель пары (card1_col1, card2_col1)
    var card2_col2: CardItem? // Победитель пары (card3_col1, card4_col1)

    var card_col3: CardItem?  // Финальный победитель

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel

        // Рассчитываем X-координаты колонок
        let baseOffsetX: CGFloat = 20 // Начальный отступ слева
        col1X = baseOffsetX + cardW / 2
        col2X = col1X + cardW / 2 + horizontalSpacing + cardW / 2
        col3X = col2X + cardW / 2 + horizontalSpacing + cardW / 2

        // Рассчитываем Y-координаты (предполагаем, что высота области около 350-400)
        // Это нужно будет настроить в зависимости от реальной высоты, выделенной в ResultPathView
        let totalBracketHeightApproximation: CGFloat = (2 * cardH + verticalSpacingInPair) * 2 + verticalSpacingBetweenPairs
        let baseOffsetY: CGFloat = 30 // Начальный отступ сверху (или (availableHeight - totalHeight) / 2)
        
        p1Y = baseOffsetY + cardH / 2
        p2Y = p1Y + cardH + verticalSpacingInPair
        p3Y = p2Y + cardH + verticalSpacingBetweenPairs
        p4Y = p3Y + cardH + verticalSpacingInPair
        
        p5Y = (p1Y + p2Y) / 2
        p6Y = (p3Y + p4Y) / 2
        
        p7Y = (p5Y + p6Y) / 2
        
        // Извлекаем карты из ViewModel
        // Колонка 1 (исходные 4 карты)
        if viewModel.allCardsForTheme.count >= 4 {
            card1_col1 = viewModel.allCardsForTheme[0]
            card2_col1 = viewModel.allCardsForTheme[1]
            card3_col1 = viewModel.allCardsForTheme[2]
            card4_col1 = viewModel.allCardsForTheme[3]
        }

        // Колонка 2 (победители первого раунда)
        // Нужно определить, кто с кем играл и кто победил
        // matchDetails[id_победителя] = (участник1, участник2)
        if let c1 = card1_col1, let c2 = card2_col1 {
            // Ищем победителя пары c1, c2
            if let winner1Id = viewModel.matchDetails.first(where: { (key, value) in
                (value.challenger1.id == c1.id && value.challenger2.id == c2.id) ||
                (value.challenger1.id == c2.id && value.challenger2.id == c1.id)
            })?.key {
                card1_col2 = viewModel.playedRounds.first?.first(where: {$0.id == winner1Id})
            }
        }
        
        if let c3 = card3_col1, let c4 = card4_col1 {
            // Ищем победителя пары c3, c4
            if let winner2Id = viewModel.matchDetails.first(where: { (key, value) in
                (value.challenger1.id == c3.id && value.challenger2.id == c4.id) ||
                (value.challenger1.id == c4.id && value.challenger2.id == c3.id)
            })?.key {
                card2_col2 = viewModel.playedRounds.first?.first(where: {$0.id == winner2Id})
            }
        }
        
        // Колонка 3 (финальный победитель)
        card_col3 = viewModel.finalWinner
        
        // Если победители не нашлись явно (например, если playedRounds[0] уже содержит их по порядку)
        // Это более простой вариант, если мы знаем порядок
        if card1_col2 == nil && viewModel.playedRounds.indices.contains(0) && viewModel.playedRounds[0].count >= 1 {
            card1_col2 = viewModel.playedRounds[0][0]
        }
        if card2_col2 == nil && viewModel.playedRounds.indices.contains(0) && viewModel.playedRounds[0].count >= 2 {
            card2_col2 = viewModel.playedRounds[0][1]
        }
    }
    
    var body: some View {
        // ZStack будет иметь свой frame от родителя (BracketView в ResultPathView)
        ZStack {
            // --- Connectors Path ---
            Path { path in
                let lineOffset: CGFloat = horizontalSpacing * 0.35 // Как далеко линии идут горизонтально от карт

                // Проверяем, что все нужные карты есть для рисования линий
                guard card1_col1 != nil, card2_col1 != nil, card3_col1 != nil, card4_col1 != nil,
                      let winner1_col2 = card1_col2, let winner2_col2 = card2_col2,
                      let finalWinner_col3 = card_col3 else {
                    print("PrizerBracketView4: Not enough card data to draw all lines.")
                    return
                }

                // --- Group 1: card1_col1 & card2_col1 -> winner1_col2 ---
                let j1X = col1X + cardW / 2 + lineOffset
                let j1Y = p5Y
                
                path.move(to: CGPoint(x: col1X + cardW / 2, y: p1Y)) // Exit card1_col1
                path.addLine(to: CGPoint(x: j1X, y: p1Y))           // Horizontal
                path.addLine(to: CGPoint(x: j1X, y: j1Y))           // Vertical to winner Y
                
                path.move(to: CGPoint(x: col1X + cardW / 2, y: p2Y)) // Exit card2_col1
                path.addLine(to: CGPoint(x: j1X, y: p2Y))           // Horizontal
                path.addLine(to: CGPoint(x: j1X, y: j1Y))           // Vertical to winner Y (joins previous vertical)
                
                path.addLine(to: CGPoint(x: col2X - cardW / 2, y: j1Y)) // To winner1_col2 entry

                // --- Group 2: card3_col1 & card4_col1 -> winner2_col2 ---
                let j2X = col1X + cardW / 2 + lineOffset
                let j2Y = p6Y
                
                path.move(to: CGPoint(x: col1X + cardW / 2, y: p3Y)) // Exit card3_col1
                path.addLine(to: CGPoint(x: j2X, y: p3Y))
                path.addLine(to: CGPoint(x: j2X, y: j2Y))
                
                path.move(to: CGPoint(x: col1X + cardW / 2, y: p4Y)) // Exit card4_col1
                path.addLine(to: CGPoint(x: j2X, y: p4Y))
                path.addLine(to: CGPoint(x: j2X, y: j2Y))
                
                path.addLine(to: CGPoint(x: col2X - cardW / 2, y: j2Y)) // To winner2_col2 entry

                // --- Group 3: winner1_col2 & winner2_col2 -> finalWinner_col3 ---
                let j3X = col2X + cardW / 2 + lineOffset
                let j3Y = p7Y
                
                path.move(to: CGPoint(x: col2X + cardW / 2, y: p5Y)) // Exit winner1_col2
                path.addLine(to: CGPoint(x: j3X, y: p5Y))
                path.addLine(to: CGPoint(x: j3X, y: j3Y))
                
                path.move(to: CGPoint(x: col2X + cardW / 2, y: p6Y)) // Exit winner2_col2
                path.addLine(to: CGPoint(x: j3X, y: p6Y))
                path.addLine(to: CGPoint(x: j3X, y: j3Y))
                
                path.addLine(to: CGPoint(x: col3X - cardW / 2, y: j3Y)) // To finalWinner_col3 entry
            }
            .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .shadow(color: .neonGreen.opacity(0.5), radius: 3)
            
            
            // --- Cards ---
            // Column 1
            if let card = card1_col1 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col1X, y: p1Y)
            }
            if let card = card2_col1 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col1X, y: p2Y)
            }
            if let card = card3_col1 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col1X, y: p3Y)
            }
            if let card = card4_col1 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col1X, y: p4Y)
            }
            
            // Column 2
            if let card = card1_col2 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col2X, y: p5Y)
            }
            if let card = card2_col2 {
                BracketCardItemView(card: card, isSelected: viewModel.wasChosen(card: card), isFinalWinner: card.id == viewModel.finalWinner?.id)
                    .position(x: col2X, y: p6Y)
            }
            
            // Column 3
            if let card = card_col3 {
                BracketCardItemView(card: card, isSelected: true, isFinalWinner: true) // Финальный победитель всегда выбран
                    .position(x: col3X, y: p7Y)
            }
        }
    }
}

struct PrizerBracketView8: View {
    @ObservedObject var viewModel: GameViewModel

    // --- Configuration for Layout ---
    let cardW = BracketCardItemView.cardWidth
    let cardH = BracketCardItemView.cardHeight
    
    // Горизонтальные отступы между центрами колонок карт
    let hSpacingCol1_2: CGFloat = BracketCardItemView.cardWidth + 50 // Пространство между колонкой 1 и 2
    let hSpacingCol2_3: CGFloat = BracketCardItemView.cardWidth + 50 // Пространство между колонкой 2 и 3
    let hSpacingCol3_4: CGFloat = BracketCardItemView.cardWidth + 50 // Пространство между колонкой 3 и 4

    // Вертикальные отступы
    let vSpacingInPair: CGFloat = 15 // Между картами в одной паре первого раунда
    let vSpacingBetweenPairs: CGFloat = 25 // Между группами пар в первом раунде

    // --- Координаты X для центров колонок ---
    let col1X: CGFloat
    let col2X: CGFloat
    let col3X: CGFloat
    let col4X: CGFloat // Финальный победитель

    // --- Координаты Y для центров карт ---
    // Колонка 1 (8 карт)
    let p1Y, p2Y, p3Y, p4Y, p5Y, p6Y, p7Y, p8Y: CGFloat
    // Колонка 2 (4 карты)
    let p9Y, p10Y, p11Y, p12Y: CGFloat
    // Колонка 3 (2 карты)
    let p13Y, p14Y: CGFloat
    // Колонка 4 (1 карта - победитель)
    let p15Y: CGFloat

    // --- Карты ---
    // Колонка 1
    var c1_1, c1_2, c1_3, c1_4, c1_5, c1_6, c1_7, c1_8: CardItem?
    // Колонка 2
    var c2_1, c2_2, c2_3, c2_4: CardItem?
    // Колонка 3
    var c3_1, c3_2: CardItem?
    // Колонка 4
    var c4_1: CardItem? // Финальный победитель

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel

        let baseOffsetX: CGFloat = 20 // Начальный отступ слева
        col1X = baseOffsetX + cardW / 2
        col2X = col1X + hSpacingCol1_2
        col3X = col2X + hSpacingCol2_3
        col4X = col3X + hSpacingCol3_4

        // Примерная общая высота для центрирования. Это значение нужно будет подогнать
        // или получать из GeometryReader в родительском View.
        // (4 * cardH + 3 * vSpacingInPair) для одной "четвертинки" + 3 * vSpacingBetweenPairs
        let estimatedTotalHeight: CGFloat = (4 * (cardH + vSpacingInPair) - vSpacingInPair) + 3 * vSpacingBetweenPairs
        let baseOffsetY: CGFloat = 30 // или (availableHeight - estimatedTotalHeight) / 2
        
        // Y для колонки 1
        p1Y = baseOffsetY + cardH / 2
        p2Y = p1Y + cardH + vSpacingInPair
        p3Y = p2Y + cardH + vSpacingBetweenPairs
        p4Y = p3Y + cardH + vSpacingInPair
        p5Y = p4Y + cardH + vSpacingBetweenPairs
        p6Y = p5Y + cardH + vSpacingInPair
        p7Y = p6Y + cardH + vSpacingBetweenPairs
        p8Y = p7Y + cardH + vSpacingInPair

        // Y для колонки 2
        p9Y = (p1Y + p2Y) / 2
        p10Y = (p3Y + p4Y) / 2
        p11Y = (p5Y + p6Y) / 2
        p12Y = (p7Y + p8Y) / 2
        
        // Y для колонки 3
        p13Y = (p9Y + p10Y) / 2
        p14Y = (p11Y + p12Y) / 2
        
        // Y для колонки 4
        p15Y = (p13Y + p14Y) / 2

        // --- Извлечение карт ---
        let initialCards = viewModel.allCardsForTheme
        let winnersR1 = viewModel.playedRounds.indices.contains(0) ? viewModel.playedRounds[0] : []
        let winnersR2 = viewModel.playedRounds.indices.contains(1) ? viewModel.playedRounds[1] : []
        
        c1_1 = initialCards.count > 0 ? initialCards[0] : nil
        c1_2 = initialCards.count > 1 ? initialCards[1] : nil
        c1_3 = initialCards.count > 2 ? initialCards[2] : nil
        c1_4 = initialCards.count > 3 ? initialCards[3] : nil
        c1_5 = initialCards.count > 4 ? initialCards[4] : nil
        c1_6 = initialCards.count > 5 ? initialCards[5] : nil
        c1_7 = initialCards.count > 6 ? initialCards[6] : nil
        c1_8 = initialCards.count > 7 ? initialCards[7] : nil

        // Для колонок победителей используем matchDetails, чтобы правильно сопоставить
        func findWinnerOfPair(_ cardA: CardItem?, _ cardB: CardItem?, inPotentialWinners: [CardItem]) -> CardItem? {
            guard let ca = cardA, let cb = cardB else { return nil }
            if let winnerId = viewModel.matchDetails.first(where: { (key, value) in
                (value.challenger1.id == ca.id && value.challenger2.id == cb.id) ||
                (value.challenger1.id == cb.id && value.challenger2.id == ca.id)
            })?.key {
                return inPotentialWinners.first(where: { $0.id == winnerId })
            }
            return nil
        }

        c2_1 = findWinnerOfPair(c1_1, c1_2, inPotentialWinners: winnersR1)
        c2_2 = findWinnerOfPair(c1_3, c1_4, inPotentialWinners: winnersR1)
        c2_3 = findWinnerOfPair(c1_5, c1_6, inPotentialWinners: winnersR1)
        c2_4 = findWinnerOfPair(c1_7, c1_8, inPotentialWinners: winnersR1)
        
        c3_1 = findWinnerOfPair(c2_1, c2_2, inPotentialWinners: winnersR2)
        c3_2 = findWinnerOfPair(c2_3, c2_4, inPotentialWinners: winnersR2)
        
        c4_1 = viewModel.finalWinner
        
        // Резервный вариант, если matchDetails не дал результата (менее надежно)
        if c2_1 == nil && winnersR1.count > 0 { c2_1 = winnersR1[0] }
        if c2_2 == nil && winnersR1.count > 1 { c2_2 = winnersR1[1] }
        if c2_3 == nil && winnersR1.count > 2 { c2_3 = winnersR1[2] }
        if c2_4 == nil && winnersR1.count > 3 { c2_4 = winnersR1[3] }

        if c3_1 == nil && winnersR2.count > 0 { c3_1 = winnersR2[0] }
        if c3_2 == nil && winnersR2.count > 1 { c3_2 = winnersR2[1] }
    }


    var body: some View {
            ZStack {
                // --- Connectors Path ---
                Path { path in
                    // ... (ваш код для рисования линий остается здесь) ...
                     let lineOffset: CGFloat = hSpacingCol1_2 * 0.35

                    func drawConnectionGroup(
                        p1X: CGFloat, p1Y: CGFloat,
                        p2X: CGFloat, p2Y: CGFloat,
                        winnerX: CGFloat, winnerY: CGFloat,
                        junctionXOffset: CGFloat
                    ) {
                        let junctionX = p1X + cardW / 2 + junctionXOffset
                        
                        path.move(to: CGPoint(x: p1X + cardW / 2, y: p1Y))
                        path.addLine(to: CGPoint(x: junctionX, y: p1Y))
                        path.addLine(to: CGPoint(x: junctionX, y: winnerY))
                        
                        path.move(to: CGPoint(x: p2X + cardW / 2, y: p2Y))
                        path.addLine(to: CGPoint(x: junctionX, y: p2Y))
                        path.addLine(to: CGPoint(x: junctionX, y: winnerY))
                        
                        path.addLine(to: CGPoint(x: winnerX - cardW / 2, y: winnerY))
                    }

                    if c1_1 != nil, c1_2 != nil, c2_1 != nil {
                        drawConnectionGroup(p1X: col1X, p1Y: p1Y, p2X: col1X, p2Y: p2Y, winnerX: col2X, winnerY: p9Y, junctionXOffset: lineOffset)
                    }
                    if c1_3 != nil, c1_4 != nil, c2_2 != nil {
                        drawConnectionGroup(p1X: col1X, p1Y: p3Y, p2X: col1X, p2Y: p4Y, winnerX: col2X, winnerY: p10Y, junctionXOffset: lineOffset)
                    }
                    if c1_5 != nil, c1_6 != nil, c2_3 != nil {
                        drawConnectionGroup(p1X: col1X, p1Y: p5Y, p2X: col1X, p2Y: p6Y, winnerX: col2X, winnerY: p11Y, junctionXOffset: lineOffset)
                    }
                    if c1_7 != nil, c1_8 != nil, c2_4 != nil {
                        drawConnectionGroup(p1X: col1X, p1Y: p7Y, p2X: col1X, p2Y: p8Y, winnerX: col2X, winnerY: p12Y, junctionXOffset: lineOffset)
                    }

                    if c2_1 != nil, c2_2 != nil, c3_1 != nil {
                        drawConnectionGroup(p1X: col2X, p1Y: p9Y, p2X: col2X, p2Y: p10Y, winnerX: col3X, winnerY: p13Y, junctionXOffset: lineOffset)
                    }
                    if c2_3 != nil, c2_4 != nil, c3_2 != nil {
                        drawConnectionGroup(p1X: col2X, p1Y: p11Y, p2X: col2X, p2Y: p12Y, winnerX: col3X, winnerY: p14Y, junctionXOffset: lineOffset)
                    }
                    
                    if c3_1 != nil, c3_2 != nil, c4_1 != nil {
                        drawConnectionGroup(p1X: col3X, p1Y: p13Y, p2X: col3X, p2Y: p14Y, winnerX: col4X, winnerY: p15Y, junctionXOffset: lineOffset)
                    }
                }
                .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .shadow(color: .neonGreen.opacity(0.5), radius: 3)

                // --- Карты ---
                let cardsCol1 = [c1_1, c1_2, c1_3, c1_4, c1_5, c1_6, c1_7, c1_8]
                let posYCol1 = [p1Y, p2Y, p3Y, p4Y, p5Y, p6Y, p7Y, p8Y]
                
                let cardsCol2 = [c2_1, c2_2, c2_3, c2_4]
                let posYCol2 = [p9Y, p10Y, p11Y, p12Y]
                
                let cardsCol3 = [c3_1, c3_2]
                let posYCol3 = [p13Y, p14Y]

                // Отображаем колонки используя новый CardColumnView
                CardColumnView(cards: cardsCol1, positionsY: posYCol1, columnX: col1X, viewModel: viewModel)
                CardColumnView(cards: cardsCol2, positionsY: posYCol2, columnX: col2X, viewModel: viewModel)
                CardColumnView(cards: cardsCol3, positionsY: posYCol3, columnX: col3X, viewModel: viewModel)

                // Финальный победитель
                if let winnerCard = c4_1 {
                    BracketCardItemView(
                        card: winnerCard,
                        isSelected: true,
                        isFinalWinner: true
                    )
                    .position(x: col4X, y: p15Y)
                }
            }
        }
    }


struct CardColumnView: View {
    let cards: [CardItem?]
    let positionsY: [CGFloat]
    let columnX: CGFloat
    let viewModel: GameViewModel // Нужен для isSelected/isFinalWinner

    var body: some View {
        ForEach(0..<cards.count, id: \.self) { index in
            if let card = cards[index] {
                BracketCardItemView(
                    card: card,
                    isSelected: viewModel.wasChosen(card: card), // Используем viewModel
                    isFinalWinner: card.id == viewModel.finalWinner?.id
                )
                .position(x: columnX, y: positionsY[index])
            }
        }
    }
}
