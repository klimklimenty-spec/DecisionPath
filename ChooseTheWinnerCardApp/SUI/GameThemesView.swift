//
//  GameThemesView.swift
//  PP
//
//  Created by D K on 12.05.2025.
//

import SwiftUI


struct GameThemesView: View {
    let themes = DataManager.shared.predefinedThemes

    @State private var selectedGameViewModel: GameViewModel? = nil
    @State private var isGamePresented: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""


    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundStyle(.darkBlue)
                .ignoresSafeArea()
            

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Main Game")
                        .font(.largeTitle.bold())
                        .foregroundColor(.neonGreen)

                    Text("Pick one of the themes for the game")
                        .font(.headline)
                        .foregroundColor(.lightGreen)

                    ForEach(themes) { theme in
                        ThemeRow(theme: theme) {
                            // Действие при нажатии на тему
                            prepareAndStartGame(for: theme)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 100) // Для TabBar
            }
            .padding(.bottom, 50)
        }
        // .navigationBarHidden(true) // Если NavigationView все же используется где-то выше
        .fullScreenCover(item: $selectedGameViewModel) { viewModel in // Используем item для опционального объекта
            GamePlayView(viewModel: viewModel)
                .interactiveDismissDisabled() // Опционально: запретить свайп для закрытия
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Game Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func prepareAndStartGame(for theme: GameTheme) {
        let cardsForTheme = DataManager.shared.getCards(for: theme.title)
        let n = cardsForTheme.count
        if n == 0 {
            alertMessage = "No cards available for the theme '\(theme.title)'."
            showAlert = true
            return
        }
        
        let isPowerOfTwo = (n > 0) && ((n & (n - 1)) == 0)
        if n == 1 || isPowerOfTwo {
            self.selectedGameViewModel = GameViewModel(theme: theme, mockCards: cardsForTheme)
            // self.isGamePresented = true // Больше не нужно, так как .sheet(item:) используется
        } else {
            print("Error: Number of cards for theme '\(theme.title)' is \(n), which is not 1 or a power of 2. Cannot start game.")
            alertMessage = "The number of cards for '\(theme.title)' (\(n)) is not valid for a tournament (must be 1, 2, 4, 8, etc.)."
            showAlert = true
        }
    }
}

import SwiftUI

struct ThemeRow: View {
    
    
    let theme: GameTheme
    let action: () -> Void

    // Цвета можно вынести в Color extension, если они часто используются
    let startGradient = Color.deepPurple
    let endGradient = Color(red: 68/255, green: 32/255, blue: 91/255) // Чуть светлее фиолетовый
    let iconBackgroundColor = Color.neonGreen // Оставим яркий акцент
    let textColor = Color.white // Сделаем текст белым для лучшего контраста с градиентом
    let accentIconColor = Color.buttonTextYellow // Для шеврона

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                // Иконка
                ZStack {
                    // Можно добавить легкий эффект "вдавливания" или второй круг для объема
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.2)) // Полупрозрачный фон под иконкой
                        .frame(width: 52, height: 52)
                    
                    Image(theme.iconName)
                        .resizable()
                        //.renderingMode(.template) // Если иконки одноцветные и нужно менять цвет
                        .foregroundColor(Color.deepPurple) // Цвет самой иконки
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .background(iconBackgroundColor)
                        .clipShape(Circle())
                        .shadow(color: iconBackgroundColor.opacity(0.5), radius: 3, x: 0, y: 2) // Тень для иконки
                }

                // Текст темы
                Text(theme.title)
                    .font(.system(size: 18, weight: .semibold)) // Немного увеличим и сделаем жирнее
                    .foregroundColor(textColor)
                    .lineLimit(2) // На случай длинных названий
                    .multilineTextAlignment(.leading)

                Spacer()

                // Шеврон
                Image(systemName: "chevron.right.circle.fill") // Более стильный шеврон
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(accentIconColor.opacity(0.8))
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                LinearGradient(gradient: Gradient(colors: [.darkBlue, .semiBlue]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(20) // Более скругленные углы
            .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 3) // Тень для кнопки
            .overlay( // Неоновая обводка (опционально)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Убираем стандартное поведение затемнения кнопки при нажатии
    }
}
struct GameThemesView_Previews: PreviewProvider {
    static var previews: some View {
        GameThemesView()
            .preferredColorScheme(.dark)
    }
}

