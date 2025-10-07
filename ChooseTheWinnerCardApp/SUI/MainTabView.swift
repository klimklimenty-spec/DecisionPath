//
//  MainTabView.swift
//  PP
//
//  Created by D K on 12.05.2025.
//

import SwiftUI



struct MainTabView: View {
    @State private var selectedTab: Tab = .game
    @State var hasCompletedOnboarding: Bool = false

    enum Tab {
        case game
        case create
        case aiGen
        case awards
    }

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент для выбранной вкладки
            TabView(selection: $selectedTab) {
                if #available(iOS 15.0, *) {
                    GameThemesView() // Наш экран со списком тем
                        .tag(Tab.game)
                } else {
                    // Fallback on earlier versions
                }
                // Добавьте сюда View для других вкладок позже
                if #available(iOS 15.0, *) {
                    CustomThemesListView()
                        .tag(Tab.create)
                } else {
                    // Fallback on earlier versions
                }
                if #available(iOS 15.0, *) {
                    AICardGeneratorView()
                        .tag(Tab.aiGen)
                } else {
                    
                }
                if #available(iOS 15.0, *) {
                    AchievementsListView()
                        .tag(Tab.awards)
                } else {
                    // Fallback on earlier versions
                }
            }

            // Кастомный TabBar
            if #available(iOS 15.0, *) {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .fullScreenCover(isPresented: $hasCompletedOnboarding) {
            if #available(iOS 15.0, *) {
                OnboardingView()
            } else {
                // Fallback on earlier versions
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "init") {
                UserDefaults.standard.set(true, forKey: "init")
                hasCompletedOnboarding = true
            }
        }

    }
}

// Кастомный TabBar View
@available(iOS 15.0, *)
struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab

    // Цвета для активной и неактивной вкладки
    let activeColor = Color.neonGreen
    let inactiveColor = Color.gray // Можно настроить точнее

    var body: some View {
        HStack {
            TabBarButton(
                iconName: "icon_tab_game", // Ваше имя иконки для Game
                label: "GAME",
                isSelected: selectedTab == .game,
                activeColor: activeColor,
                inactiveColor: inactiveColor
            ) {
                selectedTab = .game
            }

            TabBarButton(
                iconName: "icon_tab_create", // Ваше имя иконки для Create
                label: "CREATE",
                isSelected: selectedTab == .create,
                activeColor: activeColor,
                inactiveColor: inactiveColor
            ) {
                selectedTab = .create
            }

            TabBarButton(
                iconName: "icon_tab_aigen", // Ваше имя иконки для AI Gen
                label: "AI GEN",
                isSelected: selectedTab == .aiGen,
                activeColor: activeColor,
                inactiveColor: inactiveColor
            ) {
                selectedTab = .aiGen
            }

            TabBarButton(
                iconName: "icon_tab_awards", // Ваше имя иконки для Awards
                label: "AWARDS",
                isSelected: selectedTab == .awards,
                activeColor: activeColor,
                inactiveColor: inactiveColor
            ) {
                selectedTab = .awards
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .background(.darkBlue.opacity(0.97))
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

// Кнопка для TabBar
struct TabBarButton: View {
    let iconName: String
    let label: String
    let isSelected: Bool
    let activeColor: Color
    let inactiveColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .colorMultiply( iconName == "icon_tab_create" ? .white.opacity(0.5) : .white)
                    .colorMultiply( iconName == "icon_tab_game" ? .white.opacity(0.5) : .white)

                    .foregroundColor(isSelected ? activeColor : inactiveColor)

                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
