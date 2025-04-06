//
//  PostReviewView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData

struct PostReviewView: View {
    // Environment for model context
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Post being reviewed
    let post: Post
    
    // State variables
    @State private var userFeedback: String = ""
    @State private var isRevising: Bool = false
    @State private var isPosting: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    // Dependencies
    private let contentService = ContentGenerationService.shared
    private let postingService = SocialMediaPostingService.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Platform banner
                platformBanner
                
                // Post content section
                contentSection
                
                // Image section
                imageSection
                
                // Feedback section
                feedbackSection
                
                // Action buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Review Post")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Post Approved" || alertTitle == "Post Updated" {
                        dismiss()
                    }
                }
            )
        }
    }
    
    // Platform banner at the top
    private var platformBanner: some View {
        HStack {
            Image(systemName: platformIcon(post.platform))
                .foregroundColor(.white)
            
            Text(post.platform)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(platformColor(post.platform))
        .cornerRadius(10)
    }
    
    // Post content section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Topic
            Text("Topic")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(post.topic)
                .font(.headline)
                .padding(.bottom, 8)
            
            // Content
            Text("Content")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(post.content)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
    
    // Image preview section
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generated Image")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let imageData = post.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            } else {
                // Placeholder when no image is available
                Rectangle()
                    .fill(Color(.systemGray5))
                    .aspectRatio(1.0, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text("Image pending generation")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                    )
                    .cornerRadius(10)
            }
        }
    }
    
    // Feedback section
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Feedback")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Show previous feedback if available
            if let previousFeedback = post.userFeedback, !previousFeedback.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Previous Feedback:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(previousFeedback)
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            TextEditor(text: $userFeedback)
                .placeholder(when: userFeedback.isEmpty) {
                    Text("Enter your feedback or revision requests here...")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                .frame(minHeight: 100)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // Action buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Request revision button
            Button(action: requestRevision) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Request Revision")
                    
                    if isRevising {
                        Spacer()
                        ProgressView()
                            .tint(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
            }
            .disabled(userFeedback.isEmpty || isRevising || isPosting)
            
            // Approve and post button
            Button(action: approveAndPost) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Approve & Post")
                    
                    if isPosting {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isRevising || isPosting)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Actions
    
    // Request a revision of the post
    private func requestRevision() {
        guard !userFeedback.isEmpty else { return }
        
        isRevising = true
        post.userFeedback = userFeedback
        post.status = .inRevision
        
        // In a real app, this would call the ContentGenerationService
        // For now, just simulate with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate revised content
            post.content = "REVISED: \(post.content)\n\nRevised based on feedback: \(userFeedback)"
            
            // Save changes to the model context
            do {
                try modelContext.save()
                alertTitle = "Post Updated"
                alertMessage = "The post has been revised based on your feedback."
                showingAlert = true
            } catch {
                alertTitle = "Error"
                alertMessage = "Failed to save revision: \(error.localizedDescription)"
                showingAlert = true
            }
            
            self.isRevising = false
            self.userFeedback = ""
        }
    }
    
    // Approve and post to social media
    private func approveAndPost() {
        isPosting = true
        post.status = .approved
        
        // Save any feedback if provided
        if !userFeedback.isEmpty {
            post.userFeedback = userFeedback
        }
        
        // In a real app, this would call the SocialMediaPostingService
        // For now, just simulate with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate posting
            post.status = .posted
            post.postDate = Date()
            
            // Save changes to the model context
            do {
                try modelContext.save()
                alertTitle = "Post Approved"
                alertMessage = "The post has been approved and scheduled for posting to \(post.platform)."
                showingAlert = true
            } catch {
                alertTitle = "Error"
                alertMessage = "Failed to approve post: \(error.localizedDescription)"
                showingAlert = true
            }
            
            self.isPosting = false
        }
    }
    
    // Helper to get platform icon
    private func platformIcon(_ platform: String) -> String {
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
    
    // Helper to get platform color
    private func platformColor(_ platform: String) -> Color {
        switch platform {
        case "Facebook":
            return .blue
        case "Instagram":
            return .purple
        case "TikTok":
            return .cyan
        case "X":
            return .black
        case "LinkedIn":
            return .indigo
        default:
            return .gray
        }
    }
}

// Extension to add placeholder to TextEditor
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    NavigationStack {
        PostReviewView(
            post: Post(
                topic: "Seasonal Car Care",
                content: "As temperatures drop, it's important to prepare your vehicle for winter. Make sure to check your battery, antifreeze, tires, and windshield wipers. Schedule a winter check-up with our expert technicians today!",
                platform: "Facebook",
                status: .pendingReview
            )
        )
    }
    .modelContainer(for: Post.self, inMemory: true)
}
