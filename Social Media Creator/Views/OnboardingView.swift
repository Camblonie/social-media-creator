//
//  OnboardingView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI

struct OnboardingView: View {
    // State to track which page we're on
    @State private var currentPage = 0
    
    // State to track when onboarding is complete
    @Binding var isOnboardingComplete: Bool
    
    // Onboarding page data
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Social Media Creator",
            description: "Automate your automotive repair shop's social media presence with AI-powered content creation.",
            imageName: "car.fill",
            backgroundColor: .blue
        ),
        OnboardingPage(
            title: "AI Content Generation",
            description: "Intelligent posts created specifically for the automotive repair industry, customized for each social media platform.",
            imageName: "text.bubble.fill",
            backgroundColor: .purple
        ),
        OnboardingPage(
            title: "Custom Image Creation",
            description: "Generate professional images tailored to your content using advanced AI technology.",
            imageName: "photo.fill",
            backgroundColor: .orange
        ),
        OnboardingPage(
            title: "Scheduled Posting",
            description: "Set up your posting schedule and let the app handle the rest. Choose which days and platforms to post to.",
            imageName: "calendar",
            backgroundColor: .green
        )
    ]
    
    var body: some View {
        ZStack {
            // Background color
            pages[currentPage].backgroundColor
                .ignoresSafeArea()
            
            // Content
            VStack {
                // Header with skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        // Skip to the end
                        isOnboardingComplete = true
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                // Spacer to push content down
                Spacer()
                
                // Icon
                Image(systemName: pages[currentPage].imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                
                // Title
                Text(pages[currentPage].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description
                Text(pages[currentPage].description)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                
                // Spacer to push content up
                Spacer()
                
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom, 24)
                
                // Button to continue or finish
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(pages[currentPage].backgroundColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

// Struct to represent an onboarding page
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// Preview for SwiftUI canvas
#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
