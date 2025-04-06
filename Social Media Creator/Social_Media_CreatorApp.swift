//
//  Social_Media_CreatorApp.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData

@main
struct Social_Media_CreatorApp: App {
    // State to track if onboarding has been completed
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Define all our models
            SocialMediaPlatform.self,
            Post.self,
            AppSettings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                // Main app navigation
                MainView()
            } else {
                // Onboarding flow
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
