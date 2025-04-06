//
//  ContentView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Environment for accessing the model context
    @Environment(\.modelContext) private var modelContext
    
    // State for tracking the currently selected tab
    @State private var selectedTab = 0
    
    // Check if setup is completed
    @Query private var settings: [AppSettings]
    
    // Check if setup needs to be completed
    private var needsSetup: Bool {
        return settings.isEmpty
    }
    
    var body: some View {
        Group {
            if needsSetup {
                // If setup is not completed, show the setup view
                SetupView()
            } else {
                // Main tabbed interface
                TabView(selection: $selectedTab) {
                    // Main view
                    NavigationStack {
                        MainView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    // Posts review
                    NavigationStack {
                        PendingReviewListView()
                    }
                    .tabItem {
                        Label("Review", systemImage: "checklist")
                    }
                    .tag(1)
                    
                    // Settings
                    NavigationStack {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
                }
                .onAppear {
                    // Check for pending posts to review and set badge
                    checkForPendingReviews()
                }
            }
        }
    }
    
    // Check for pending posts and update the badge
    private func checkForPendingReviews() {
        // In a real app, this would query for pending reviews and set the badge
        // This is handled differently in newer iOS versions with badge modifiers
        
        // For now, we're using the tab-based navigation to access these views
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [AppSettings.self, SocialMediaPlatform.self, Post.self], inMemory: true)
}
