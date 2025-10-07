//
//  AchievementsListView.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import SwiftUI

@available(iOS 15.0, *)
struct AchievementsListView: View {
    
    @StateObject var achievementsService = AchievementsService()

    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundStyle(.darkBlue)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("My Achievements")
                        .font(.largeTitle.bold())
                        .foregroundColor(.neonGreen)
                        .padding(.top, 20)
                        .padding(.bottom, 15)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(achievementsService.achievements) { achievement in
                                AchievementRowView(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                achievementsService.refreshAchievementsStatus()
            }
        }
    }
}

struct AchievementRowView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 15) {
            Image(achievement.isUnlocked ? achievement.type.unlockedIconName : achievement.type.lockedIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .padding(8)
                .background(
                    (achievement.isUnlocked ? Color.neonGreen : Color.gray.opacity(0.5))
                        .opacity(0.2)
                )
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(achievement.isUnlocked ? Color.neonGreen : Color.gray, lineWidth: 1.5)
                )
                .shadow(color: achievement.isUnlocked ? Color.neonGreen.opacity(0.5) : Color.clear, radius: achievement.isUnlocked ? 5 : 0)

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.type.title)
                    .font(.headline.bold())
                    .foregroundColor(achievement.isUnlocked ? .buttonTextYellow : .white.opacity(0.8))
                
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.9) : .gray)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.deepPurple.opacity(achievement.isUnlocked ? 0.9 : 0.7),
                    Color.deepPurple.opacity(achievement.isUnlocked ? 0.7 : 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .opacity(achievement.isUnlocked ? 1.0 : 0.75)
    }
}

