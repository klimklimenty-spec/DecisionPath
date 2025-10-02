//
//  AICardGeneratorView.swift
//  PP
//
//  Created by D K on 14.05.2025.
//

import Foundation
import SwiftUI

struct AICardGeneratorView: View {
    @StateObject private var viewModel = AICardGeneratorViewModel()
    
    
    @StateObject var achievementsService = AchievementsService()
    
    @State private var achievementForAlert: Achievement? = nil
    @State private var showAchievementAlert: Bool = false
    let aiPioneerUserDefaultsKey = "prizer_didUnlockAIPioneer"
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundStyle(.darkBlue)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("AI Powered Picker")
                            .font(.largeTitle.bold())
                            .foregroundColor(.neonGreen)
                            .padding(.bottom, 5)
                        
                        Text("Enter your theme or prompt, and let AI generate the cards for you!")
                            .font(.headline)
                            .foregroundColor(.lightGreen)
                            .padding(.bottom, 15)
                        
                        // MARK: - Prompt Input
                        Text("Your Prompt")
                            .sectionTitleStyleAI()
                        
                        TextEditor(text: $viewModel.userPrompt)
                            .frame(height: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.neonGreen.opacity(0.6), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .accentColor(.neonGreen)
                            .font(.system(size: 16))
                            .padding(4)
                        
                        // MARK: - Number of Cards
                        Text("Number of Cards")
                            .sectionTitleStyleAI()
                        
                        Picker("Number of Cards", selection: $viewModel.numberOfCards) {
                            Text("4 Cards").tag(4)
                            Text("8 Cards").tag(8)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .preferredColorScheme(.dark)
                        .colorMultiply(.neonGreen)
                        
                        // MARK: - Generate Button & Loading
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                                    .scaleEffect(1.5)
                                Text("Generating...")
                                    .foregroundColor(.neonGreen)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                        } else {
                            Button(action: {
                                viewModel.generateAndPlay()
                            }) {
                                Text("Generate & Play")
                                    .font(.headline.bold())
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.canGenerate ? Color.neonGreen : Color.gray.opacity(0.5))
                                    .foregroundColor(viewModel.canGenerate ? .deepPurple : .gray)
                                    .cornerRadius(15)
                                    .shadow(color: viewModel.canGenerate ? Color.neonGreen.opacity(0.5) : Color.clear, radius: 8, y: 4)
                            }
                            .disabled(!viewModel.canGenerate)
                            .padding(.top, 20)
                        }
                        
                        // MARK: - Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.pink)
                                .padding(.top, 10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.showGamePlayView) {
                if let gameVM = viewModel.gameViewModelForAIGame {
                    GamePlayView(viewModel: gameVM)
                        .onDisappear {
                            showAch()
                        }
                } else {
                    Text("Error: Could not load AI game.")
                }
            }
        }
        .tint(.white)
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
        if !UserDefaults.standard.bool(forKey: aiPioneerUserDefaultsKey) {
            UserDefaults.standard.set(true, forKey: aiPioneerUserDefaultsKey)
            achievementsService.markAchievementAsUnlocked(.aiPioneer)
            
            if let achievementData = achievementsService.getAchievementData(for: .aiPioneer) {
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

// MARK: - Custom Styles for AI View (можно вынести)
struct SectionTitleStyleAI: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .foregroundColor(.neonGreen.opacity(0.9))
    }
}

extension View {
    func sectionTitleStyleAI() -> some View {
        self.modifier(SectionTitleStyleAI())
    }
}

struct NeonTextEditorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .foregroundColor(.white)
            .accentColor(.neonGreen)
            .disableAutocorrection(true)
    }
}

// MARK: - Preview
struct AICardGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        AICardGeneratorView()
            .preferredColorScheme(.dark)
    }
}
