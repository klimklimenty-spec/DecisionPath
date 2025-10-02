//
//  CustomThemesListView.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import Foundation
import SwiftUI
import RealmSwift // Для Results и @ObservedResults

struct CustomThemesListView: View {
    @ObservedResults(CustomThemeObject.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: false)) var customThemes
    
    @StateObject private var realmService = RealmService()
    
    @State private var showingCreateNewThemeView = false
    @State private var selectedThemeForGame: CustomThemeObject? = nil
    @State private var gameViewModelForSelectedTheme: GameViewModel? = nil
    @StateObject private var achievementsService = AchievementsService()
    
    @State private var achievementForAlert: Achievement? = nil
    @State private var showAchievementAlert: Bool = false
    let theCreatorUserDefaultsKey = "prizer_didUnlockTheCreator"
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundStyle(.darkBlue)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("My Custom Pickers")
                        .font(.largeTitle.bold())
                        .foregroundColor(.neonGreen)

                    Text("Pick one of the themes for the game")
                        .font(.headline)
                        .foregroundColor(.lightGreen)
                    
                    if customThemes.isEmpty {
                        PlaceholderView(
                            imageName: "plus.circle.fill",
                            title: "No Custom Pickers Yet",
                            subtitle: "Tap the button below to create your first picker!",
                            buttonText: "Create First Picker",
                            buttonAction: {
                                showingCreateNewThemeView = true
                            }
                        )
                        .padding(.horizontal)
                    } else {
                        List {
                            ForEach(customThemes) { theme in
                                CustomThemeRow(
                                    theme: theme,
                                    onPlay: {
                                        prepareAndStartGame(for: theme)
                                    },
                                    onEdit: {
                                        print("Edit theme: \(theme.title)")
                                    },
                                    onDelete: {
                                        deleteTheme(theme)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                        .padding(.bottom, 70)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .navigationBarHidden(true)
                
                if !customThemes.isEmpty {
                    FloatingActionButton(action: {
                        showingCreateNewThemeView = true
                    })
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .tint(.white)
        .fullScreenCover(isPresented: $showingCreateNewThemeView) {
            CreateEditThemeView(realmService: realmService) {}
                .onDisappear {
                    showAch()
                }
                .tint(.white)
        }
        .fullScreenCover(item: $gameViewModelForSelectedTheme) { viewModel in
            GamePlayView(viewModel: viewModel)
        }
        .overlay {
            VStack {
                if showAchievementAlert, let achievement = achievementForAlert {
                    AchievementUnlockedAlertView(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation(.easeOut(duration: 0.5)) { self.showAchievementAlert = false }
                            }
                        }
                        .zIndex(1)
                }
                Spacer()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAchievementAlert)
        }
    }
    
    func showAch() {
        if !UserDefaults.standard.bool(forKey: theCreatorUserDefaultsKey) {
            UserDefaults.standard.set(true, forKey: theCreatorUserDefaultsKey)
            achievementsService.markAchievementAsUnlocked(.theCreator)
            if let achievementData = achievementsService.getAchievementData(for: .theCreator) {
                self.achievementForAlert = achievementData
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Небольшая задержка, чтобы алерт показался после закрытия
                    withAnimation { self.showAchievementAlert = true }
                }
            }
        }
    }
    
    private func prepareAndStartGame(for customTheme: CustomThemeObject) {
        let gameCards: [CardItem] = customTheme.cards.sorted(by: { $0.sortOrder < $1.sortOrder }).map { customCard in
            CardItem(name: customCard.title, imageData: customCard.imageData)
        }
        
        let n = gameCards.count
        if n == 0 {
            print("Error: Custom theme '\(customTheme.title)' has no cards.")
            return
        }
        let isPowerOfTwo = (n > 0) && ((n & (n - 1)) == 0)
        if n == 1 || isPowerOfTwo {
            let gameThemeForPlay = GameTheme(title: customTheme.title, iconName: "icon_custom_theme_placeholder")
            self.gameViewModelForSelectedTheme = GameViewModel(theme: gameThemeForPlay, mockCards: gameCards)
        } else {
            print("Error: Number of cards for custom theme '\(customTheme.title)' is \(n), not a power of 2.")
        }
    }
    
    private func deleteTheme(_ theme: CustomThemeObject) {
        realmService.deleteTheme(withId: theme.id)
    }
}

// MARK: - Вспомогательные View

struct CustomThemeRow: View {
    let theme: CustomThemeObject
    var onPlay: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Group {
                if let firstCardImageData = theme.cards.first?.imageData,
                   let uiImage = UIImage(data: firstCardImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("icon_custom_theme_placeholder")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.neonGreen)
                }
            }
            .frame(width: 50, height: 50)
            .background(Color.neonGreen.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(5)
            .background(Color.deepPurple.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text("\(theme.numberOfCards) cards")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                onPlay()
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Button(action: onPlay) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.neonGreen)
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.pink.opacity(0.8))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.deepPurple, Color.deepPurple.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(15)
        .onTapGesture {
            onPlay()
        }
    }
}

struct PlaceholderView: View {
    let imageName: String
    let title: String
    let subtitle: String
    let buttonText: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.neonGreen.opacity(0.7))
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button(action: buttonAction) {
                Text(buttonText)
                    .font(.headline.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .foregroundColor(.deepPurple)
                    .cornerRadius(15)
                    .shadow(color: Color.neonGreen.opacity(0.5), radius: 8, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.deepPurple)
                        .padding(20)
                        .background(Color.neonGreen)
                        .clipShape(Circle())
                        .shadow(color: Color.neonGreen.opacity(0.6), radius: 10, x: 0, y: 5)
                }
            }
        }
    }
}

// MARK: - Preview
struct CustomThemesListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomThemesListView()
            .preferredColorScheme(.dark)
    }
}
