import SwiftUI
@available(iOS 15.0, *)
struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var achievementsService = AchievementsService()
    
    @State private var card1Opacity: Double = 0
    @State private var card1Scale: CGFloat = 0.7
    @State private var card1Rotation: Double = -20
    @State private var card1OffsetX: CGFloat = -50
    
    @State private var card2Opacity: Double = 0
    @State private var card2Scale: CGFloat = 0.7
    @State private var card2Rotation: Double = 20
    @State private var card2OffsetX: CGFloat = 50
    
    @State private var displayedCard1Id: UUID?
    @State private var displayedCard2Id: UUID?
    
    @State private var achievementForAlert: Achievement? = nil
    @State private var showAchievementAlert: Bool = false
    
    let firstPickUserDefaultsKey = "prizer_didUnlockFirstPick"
    
    let cardAspectRatio: CGFloat = 2/3
    let cardCornerRadius: CGFloat = 20
    let animationDuration: Double = 0.45
    let springStiffness: Double = 130
    let springDamping: Double = 13
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.darkBlue)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2.bold())
                            .foregroundColor(.neonGreen)
                    }
                    Spacer()
                    Text(viewModel.theme.title.uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.buttonTextYellow)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding()
                .frame(height: 60)
                
                Text(viewModel.gameProgressText)
                    .font(.headline)
                    .foregroundColor(.lightGreen)
                    .padding(.bottom, 20)
                    .id(viewModel.gameProgressText)
                
                Spacer()
                
                if let currentFetchedPair = viewModel.currentPair {
                    HStack(spacing: 20) {
                        CardView(card: currentFetchedPair.card1, aspectRatio: cardAspectRatio, cornerRadius: cardCornerRadius)
                            .id(currentFetchedPair.card1.id)
                            .opacity(card1Opacity)
                            .scaleEffect(card1Scale)
                            .rotation3DEffect(.degrees(card1Rotation), axis: (x: 0, y: 1, z: 0.05))
                            .offset(x: card1OffsetX)
                            .onTapGesture {
                                handleSelection(selectedCard: currentFetchedPair.card1, unselectedCardId: currentFetchedPair.card2.id)
                            }
                        
                        CardView(card: currentFetchedPair.card2, aspectRatio: cardAspectRatio, cornerRadius: cardCornerRadius)
                            .id(currentFetchedPair.card2.id)
                            .opacity(card2Opacity)
                            .scaleEffect(card2Scale)
                            .rotation3DEffect(.degrees(card2Rotation), axis: (x: 0, y: 1, z: -0.05))
                            .offset(x: card2OffsetX)
                            .onTapGesture {
                                handleSelection(selectedCard: currentFetchedPair.card2, unselectedCardId: currentFetchedPair.card1.id)
                            }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        if displayedCard1Id != currentFetchedPair.card1.id || displayedCard2Id != currentFetchedPair.card2.id {
                            triggerAppearAnimation(pair: currentFetchedPair)
                        }
                    }
                    .onChange(of: viewModel.currentPair) { newPairOptional in
                        if let newPair = newPairOptional {
                            if displayedCard1Id != newPair.card1.id || displayedCard2Id != newPair.card2.id {
                                triggerAppearAnimation(pair: newPair)
                            }
                        } else {
                            triggerDisappearAllAnimation(clearIds: true)
                        }
                    }
                } else if !viewModel.showResults {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                        .frame(maxHeight: .infinity)
                }
                
                Spacer()
                Spacer()
            }
            .blur(radius: viewModel.showResults ? 10 : 0)
            .animation(.easeInOut, value: viewModel.showResults)
            
            if viewModel.showResults {
                if #available(iOS 16.0, *) {
                    ResultPathView(
                        viewModel: viewModel,
                        onPlayAgain: {
                            viewModel.resetGame()
                        },
                        onChooseNewTheme: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .background(Color.black.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .transition(.asymmetric(insertion: .scale(scale: 0.8).combined(with: .opacity), removal: .opacity))
                    .animation(.interpolatingSpring(stiffness: springStiffness, damping: springDamping + 2), value: viewModel.showResults)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .overlay {
            VStack {
                if showAchievementAlert, let achievement = achievementForAlert {
                    AchievementUnlockedAlertView(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    self.showAchievementAlert = false
                                }
                            }
                        }
                        .zIndex(1) // Поверх остального
                }
                Spacer()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAchievementAlert)
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    private func triggerAppearAnimation(pair: GamePair) {
        resetToInitialStateBeforeAppear()
        displayedCard1Id = pair.card1.id
        displayedCard2Id = pair.card2.id
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.interpolatingSpring(stiffness: springStiffness, damping: springDamping).delay(0.1)) {
                card1Opacity = 1
                card1Scale = 1.0
                card1Rotation = 0
                card1OffsetX = 0
            }
            withAnimation(.interpolatingSpring(stiffness: springStiffness, damping: springDamping).delay(0.2)) { // Небольшая задержка для второй карты
                card2Opacity = 1
                card2Scale = 1.0
                card2Rotation = 0
                card2OffsetX = 0
            }
        }
    }
    
    private func resetToInitialStateBeforeAppear() {
        card1Opacity = 0
        card1Scale = 0.7
        card1Rotation = -20
        card1OffsetX = -50
        
        card2Opacity = 0
        card2Scale = 0.7
        card2Rotation = 20
        card2OffsetX = 50
    }
    
    private func triggerDisappearAllAnimation(clearIds: Bool) {
        withAnimation(.easeOut(duration: animationDuration / 2)) {
            card1Opacity = 0
            card1Scale = 0.7
            card1Rotation = -20
            card1OffsetX = -50
            
            card2Opacity = 0
            card2Scale = 0.7
            card2Rotation = 20
            card2OffsetX = 50
        }
        if clearIds {
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 2) {
                displayedCard1Id = nil
                displayedCard2Id = nil
            }
        }
    }
    
    private func handleSelection(selectedCard: CardItem, unselectedCardId: UUID) {
        guard let currentPair = viewModel.currentPair else { return }
        
        let isCard1Selected = selectedCard.id == currentPair.card1.id
        
        withAnimation(.interpolatingSpring(stiffness: springStiffness, damping: springDamping)) {
            if isCard1Selected {
                card1Scale = 1.05
                
                card2Opacity = 0
                card2Scale = 0.6
                card2Rotation = 30
                card2OffsetX = 80
            } else {
                card2Scale = 1.05
                
                card1Opacity = 0
                card1Scale = 0.6
                card1Rotation = -30
                card1OffsetX = -80
            }
        }
        
        showAch()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            viewModel.cardSelected(selectedCard)
        }
    }
    
    func showAch() {
        if !UserDefaults.standard.bool(forKey: firstPickUserDefaultsKey) {
            UserDefaults.standard.set(true, forKey: firstPickUserDefaultsKey)
            achievementsService.markAchievementAsUnlocked(.firstPick)
            
            if let achievementData = achievementsService.getAchievementData(for: .firstPick) {
                self.achievementForAlert = achievementData
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showAchievementAlert = true
                    }
                }
            }
        }
    }
}
