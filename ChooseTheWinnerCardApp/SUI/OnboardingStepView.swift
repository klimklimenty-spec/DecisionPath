//
//  OnboardingStep.swift
//  PP
//
//  Created by D K on 15.05.2025.
//

import SwiftUI

struct OnboardingStepView: View {
    let imageName: String // For a primary visual (could be SF Symbol or custom asset)
    let headline: String
    let subheadline: String
    // Add more properties for animation states if needed

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(imageName) // Or your custom animation view
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // Adjust as needed
                .foregroundColor(.neonGreen) // Example color
                .cornerRadius(12)
                // Add animation modifiers here

            VStack(spacing: 15) {
                Text(headline)
                    .font(.system(size: 28, weight: .bold)) // Use your app's font
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    // Add animation modifiers

                Text(subheadline)
                    .font(.system(size: 18, weight: .regular)) // Use your app's font
                    .foregroundColor(.gray) // Or lightGreen
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    // Add animation modifiers
            }
            
            Spacer()
            Spacer() // Pushes content towards center more
        }
        .padding(.horizontal, 20)
    }
}
