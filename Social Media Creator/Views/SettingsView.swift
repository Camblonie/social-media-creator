//
//  SettingsView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct SettingsView: View {
    // Environment for accessing the model context
    @Environment(\.modelContext) private var modelContext
    
    // Query for application settings
    @Query private var settings: [AppSettings]
    
    // State for topic configuration
    @State private var activeDays: Set<Weekday> = []
    @State private var dailyTopics: [String: String] = [:]
    @State private var defaultTopic: String = "Automotive maintenance tips"
    @State private var selectedDay: Weekday = .monday
    @State private var showingTopicEditor = false
    
    // State for alerts
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var alertMessage = ""
    
    // Computed property to get or create settings
    private var appSettings: AppSettings {
        if let existingSettings = settings.first {
            return existingSettings
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }
    }
    
    var body: some View {
        Form {
            // Posting schedule section
            Section(header: Text("Weekly Posting Schedule")) {
                ForEach(Weekday.allCases, id: \.self) { day in
                    Toggle(day.rawValue, isOn: binding(for: day))
                }
            }
            
            // Daily topics section
            Section(header: Text("Daily Topics")) {
                ForEach(Weekday.allCases, id: \.self) { day in
                    if activeDays.contains(day) {
                        NavigationLink {
                            topicEditorView(for: day)
                        } label: {
                            HStack {
                                Text(day.rawValue)
                                
                                Spacer()
                                
                                if let topic = dailyTopics[day.rawValue], !topic.isEmpty {
                                    Text(topic)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                } else {
                                    Text("Default topic")
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                        }
                    }
                }
            }
            
            // Default topic section
            Section(header: Text("Default Topic")) {
                TextField("Default Topic", text: $defaultTopic)
                
                Text("This topic will be used when no specific topic is assigned to a day.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Save button section
            Section {
                Button(action: saveSettings) {
                    HStack {
                        Spacer()
                        Text("Save Settings")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Advanced settings section
            Section(header: Text("Advanced Settings")) {
                NavigationLink("Application Setup") {
                    SetupView()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: loadSettings)
        .alert("Settings Saved", isPresented: $showingSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Load settings from database
    private func loadSettings() {
        let currentSettings = appSettings
        
        // Load active days
        activeDays = Set(currentSettings.activeDays)
        
        // Load daily topics
        dailyTopics = currentSettings.dailyTopics
        
        // Load default topic
        defaultTopic = currentSettings.defaultTopic
    }
    
    // Save settings to database
    private func saveSettings() {
        let currentSettings = appSettings
        
        // Update settings
        currentSettings.activeDays = Array(activeDays)
        currentSettings.dailyTopics = dailyTopics
        currentSettings.defaultTopic = defaultTopic
        
        // Try to save the model context
        do {
            try modelContext.save()
            showingSuccessAlert = true
        } catch {
            alertMessage = "Failed to save settings: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
    
    // Create a binding for a specific day's toggle
    private func binding(for day: Weekday) -> Binding<Bool> {
        Binding<Bool>(
            get: { activeDays.contains(day) },
            set: { isActive in
                if isActive {
                    activeDays.insert(day)
                    appSettings.activeDays = Array(activeDays)
                } else {
                    activeDays.remove(day)
                    appSettings.activeDays = Array(activeDays)
                }
            }
        )
    }
    
    // Topic editor view for a specific day
    private func topicEditorView(for day: Weekday) -> some View {
        let topicBinding = Binding<String>(
            get: { dailyTopics[day.rawValue] ?? "" },
            set: { dailyTopics[day.rawValue] = $0; appSettings.dailyTopics = dailyTopics }
        )
        
        return Form {
            Section(header: Text("Topic for \(day.rawValue)")) {
                TextField("Enter topic", text: topicBinding)
                    .submitLabel(.done)
                
                Button("Use Default Topic") {
                    dailyTopics[day.rawValue] = ""
                    appSettings.dailyTopics = dailyTopics
                }
                .foregroundColor(.blue)
            }
            
            Section(header: Text("Suggestions")) {
                ForEach(topicSuggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        dailyTopics[day.rawValue] = suggestion
                        appSettings.dailyTopics = dailyTopics
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Set Topic")
    }
    
    // Sample topic suggestions
    private var topicSuggestions: [String] = [
        "Seasonal Car Care",
        "DIY Auto Maintenance",
        "Vehicle Safety Tips",
        "Tire Care and Maintenance",
        "Oil Change Facts",
        "Check Engine Light Troubleshooting",
        "Brake Service and Safety",
        "Battery Care and Replacement",
        "Fuel Efficiency Tips",
        "Air Conditioning Service",
        "Transmission Maintenance",
        "Customer Success Stories",
        "Meet Our Team"
    ]
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: AppSettings.self, inMemory: true)
}
