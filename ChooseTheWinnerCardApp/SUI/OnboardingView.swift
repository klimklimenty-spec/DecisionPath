//
//  OnboardingView.swift
//  PP
//
//  Created by D K on 15.05.2025.
//

import SwiftUI



@available(iOS 15.0, *)
struct OnboardingView: View {
    @State private var currentStep = 0
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // Define your onboarding steps data
    struct OnboardingStep {
        let imageName: String // Or a more complex visual identifier
        let headline: String
        let subheadline: String
    }

    let onboardingSteps: [OnboardingStep] = [
        OnboardingStep(imageName: "onboarding_logo_placeholder", headline: "Welcome to Decision Path!", subheadline: "Life's full of choices. Decision Path makes them FUN! Pick your favorites from exciting themed cards and discover your ultimate champion."),
        OnboardingStep(imageName: "onboarding_themes_placeholder", headline: "Explore Epic Showdowns!", subheadline: "Jump right in with our curated Pickers! From sports legends to iconic gear, choose your winner in thrilling head-to-head matchups."),
        OnboardingStep(imageName: "onboarding_create_ai_placeholder", headline: "Create & Conquer!", subheadline: "Design your own Pickers with custom cards and images.\nOr, let our AI spark your imagination – just type a theme!"),
        OnboardingStep(imageName: "onboarding_achievements_placeholder", headline: "Claim Your Rewards!", subheadline: "Track your choices, complete challenges, and unlock awesome achievements. Ready to pick your first winner?")
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.darkBlue)
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentStep) {
                    ForEach(0..<onboardingSteps.count, id: \.self) { index in
                        OnboardingStepView(
                            imageName: onboardingSteps[index].imageName, // Replace with actual image/animation logic
                            headline: onboardingSteps[index].headline,
                            subheadline: onboardingSteps[index].subheadline
                        )
                        .tag(index)
                        // Add transitions for appearing/disappearing steps
                        .opacity(currentStep == index ? 1 : (currentStep > index ? 0 : 0.5)) // Basic fade
                        .animation(.easeInOut(duration: 0.5), value: currentStep)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Shows page dots
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always)) // Customize dots

                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(OnboardingButtonStyle(isPrimary: false))
                    }

                    Spacer()

                    Button(currentStep == onboardingSteps.count - 1 ? "Let's Go!" : "Next") {
                        if currentStep == onboardingSteps.count - 1 {
                            hasCompletedOnboarding = true
                            dismiss()
                            
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(OnboardingButtonStyle(isPrimary: true))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

// Custom Button Style for Onboarding
struct OnboardingButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding()
            .frame(minWidth: 120)
            .background(isPrimary ? Color.neonGreen : Color.deepPurple.opacity(0.7))
            .foregroundColor(isPrimary ? Color.deepPurple : Color.neonGreen)
            .cornerRadius(15)
            .shadow(color: (isPrimary ? Color.neonGreen : Color.deepPurple).opacity(0.4), radius: 5, y: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
