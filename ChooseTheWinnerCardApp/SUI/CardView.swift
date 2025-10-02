//
//  CardVuew.swift
//  PP
//
//  Created by D K on 13.05.2025.
//

import SwiftUI

struct CardView: View {
    let card: CardItem
    var isSelected: Bool = false
    var isWinner: Bool = false
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
            GeometryReader { geometry in
                ZStack { // Убрал alignment .bottom, если текст будет по центру
                    // Если нет изображения, используем другой фон и стиль текста
                    if card.imageData == nil && (card.imageName == nil || card.imageName!.isEmpty) {
                        // Текстовая карточка
                        LinearGradient( // Фон для текстовой карточки
                            gradient: Gradient(colors: [Color.deepPurple.opacity(0.8), Color.deepPurple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        Text(card.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(8) // Отступы для текста
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Занимает все место

                    } else { // Карточка с изображением (существующая логика)
                        ZStack(alignment: .bottom) {
                            if let imgData = card.imageData, let uiImage = UIImage(data: imgData) {
                                Image(uiImage: uiImage)
                                    .resizable().aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            } else if let imgName = card.imageName, !imgName.isEmpty {
                                Image(imgName)
                                    .resizable().aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.3))
                                Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(.white.opacity(0.7))
                            }
                            
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )

                            Text(card.name)
                                .minimumScaleFactor(0.5)
                                .font(geometry.size.height > 60 ? .headline.weight(.bold) : .caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(geometry.size.height > 60 ? 12 : 6)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor(), lineWidth: borderWidth())
                )
                .shadow(color: shadowColor().opacity(isWinner ? 0.7 : 0.5), radius: isWinner ? 10 : 5, x: 0, y: isWinner ? 4 : 2)
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
        }

    private func borderColor() -> Color {
        if isWinner {
            return .yellow
        } else if isSelected {
            return .neonGreen
        }
        return .neonGreen.opacity(0.6) // Немного тусклее для неакцентированных
    }

    private func borderWidth() -> CGFloat {
        if isWinner {
            return 3.5
        } else if isSelected {
            return 2.5
        }
        return 1.5
    }
    
    private func shadowColor() -> Color {
        if isWinner {
            return .yellow
        } else if isSelected {
            return .neonGreen
        }
        return .black // Тень для обычных карт
    }
}
