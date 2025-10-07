//
//  AchAlert.swift
//  PP
//
//  Created by D K on 15.05.2025.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
struct AchievementUnlockedAlertView: View {
    let achievement: Achievement // Теперь будет приходить уже с isUnlocked = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(achievement.type.unlockedIconName) // Всегда иконка звезды
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(.yellow)
                .padding(6)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.headline.bold())
                    .foregroundColor(.neonGreen)
                Text(achievement.type.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Material.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.neonGreen, Color.yellow.opacity(0.7)]), startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
        )
        .padding(.horizontal)
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
    }
}
