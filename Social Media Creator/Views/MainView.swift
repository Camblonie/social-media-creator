//
//  MainView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    // Environment for accessing the model context
    @Environment(\.modelContext) private var modelContext
    
    // Query the social media platforms
    @Query private var platforms: [SocialMediaPlatform]
    
    // Query posts that need review
    @Query private var postsNeedingReview: [Post]
    
    // State for the selected topic
    @State private var selectedTopic = "Auto Maintenance Tips"
    @State private var showingTopicPicker = false
    @State private var isGeneratingContent = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Initialize the query for posts needing review
    init() {
        // Create a default Query without a predicate
        // The correct type parameters for Query should be Query<Element, [Element]>
        _postsNeedingReview = Query<Post, [Post]>()
    }
    
    // Computed property to filter posts needing review
    private var filteredPostsNeedingReview: [Post] {
        return postsNeedingReview.filter { post in
            post.status == .pendingReview
        }
    }
    
    // Sample topics for the picker
    private let topics = [
        "Auto Maintenance Tips", "Seasonal Car Care", "DIY Auto Repairs",
        "Vehicle Safety", "Tire Maintenance", "Oil Change Facts",
        "Check Engine Light", "Brake Service", "Battery Care",
        "Fuel Efficiency", "Air Conditioning", "Transmission Service"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Pending review count badge
                if !filteredPostsNeedingReview.isEmpty {
                    NavigationLink(destination: PendingReviewListView()) {
                        HStack {
                            Text("\(filteredPostsNeedingReview.count) \(filteredPostsNeedingReview.count == 1 ? "post" : "posts") pending review")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                // Platform toggles
                platformsSection
                
                Divider()
                    .padding(.horizontal)
                
                // Create now section
                createNowSection
                
                Spacer()
            }
            .navigationTitle("Social Media Creator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear(perform: setupPlatformsIfNeeded)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Information"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // Platform toggles section
    private var platformsSection: some View {
        VStack(alignment: .leading) {
            Text("Active Platforms")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(platforms) { platform in
                        PlatformToggleRow(platform: platform, modelContext: modelContext)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 280)
        }
    }
    
    // Create now section
    private var createNowSection: some View {
        VStack(alignment: .leading) {
            Text("Create Content Now")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Selected topic display
                HStack {
                    Text("Topic:")
                        .foregroundColor(.secondary)
                    
                    Text(selectedTopic)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: {
                        showingTopicPicker = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Create now button
                Button(action: createContent) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Create Content")
                        
                        if isGeneratingContent {
                            Spacer()
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isGeneratingContent)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .sheet(isPresented: $showingTopicPicker) {
            topicPickerView
        }
    }
    
    // Topic picker view presented as a sheet
    private var topicPickerView: some View {
        NavigationStack {
            List {
                ForEach(topics, id: \.self) { topic in
                    Button(action: {
                        selectedTopic = topic
                        showingTopicPicker = false
                    }) {
                        HStack {
                            Text(topic)
                            Spacer()
                            if selectedTopic == topic {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingTopicPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // Initialize default platforms if none exist
    private func setupPlatformsIfNeeded() {
        // Only create default platforms if none exist
        if platforms.isEmpty {
            for platform in SocialMediaPlatform.defaultPlatforms() {
                modelContext.insert(platform)
            }
            
            // Try to save the model context
            do {
                try modelContext.save()
            } catch {
                print("Failed to save default platforms: \(error)")
            }
        }
    }
    
    // Create content for the selected topic and active platforms
    private func createContent() {
        // Check if any platforms are active
        let activePlatforms = platforms.filter { $0.isActive }
        guard !activePlatforms.isEmpty else {
            alertMessage = "Please enable at least one social media platform."
            showingAlert = true
            return
        }
        
        // Create content for each active platform
        isGeneratingContent = true
        
        // In a real app, this would call the ContentGenerationService
        // For now, just simulate the process with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            for platform in activePlatforms {
                let newPost = Post(
                    topic: self.selectedTopic,
                    content: "This is a sample post about \(self.selectedTopic) for \(platform.name).",
                    platform: platform.name,
                    status: .pendingReview,
                    targetPlatformID: platform.id
                )
                
                self.modelContext.insert(newPost)
            }
            
            // Try to save the model context
            do {
                try self.modelContext.save()
                self.alertMessage = "Content created! Please review before posting."
                self.showingAlert = true
            } catch {
                self.alertMessage = "Failed to create content: \(error.localizedDescription)"
                self.showingAlert = true
            }
            
            self.isGeneratingContent = false
        }
    }
}

// Platform toggle row component
struct PlatformToggleRow: View {
    let platform: SocialMediaPlatform
    let modelContext: ModelContext
    @State private var isActive: Bool
    
    init(platform: SocialMediaPlatform, modelContext: ModelContext) {
        self.platform = platform
        self.modelContext = modelContext
        self._isActive = State(initialValue: platform.isActive)
    }
    
    var body: some View {
        HStack {
            // Platform icon
            Image(systemName: iconName(for: platform.name))
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(iconColor(for: platform.name))
            
            // Platform name
            Text(platform.name)
                .fontWeight(.medium)
            
            Spacer()
            
            // Toggle switch
            Toggle("", isOn: $isActive)
                .labelsHidden()
                .onChange(of: isActive) { oldValue, newValue in
                    platform.isActive = newValue
                    try? modelContext.save()
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Get icon name for each platform
    private func iconName(for platform: String) -> String {
        switch platform {
        case "Facebook":
            return "f.square.fill"
        case "Instagram":
            return "camera.fill"
        case "TikTok":
            return "music.note"
        case "X":
            return "x.square.fill"
        case "LinkedIn":
            return "briefcase.fill"
        default:
            return "globe"
        }
    }
    
    // Get icon color for each platform
    private func iconColor(for platform: String) -> Color {
        switch platform {
        case "Facebook":
            return Color.blue
        case "Instagram":
            return Color.purple
        case "TikTok":
            return Color.cyan
        case "X":
            return Color.black
        case "LinkedIn":
            return Color.blue
        default:
            return Color.gray
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [SocialMediaPlatform.self, Post.self], inMemory: true)
}
