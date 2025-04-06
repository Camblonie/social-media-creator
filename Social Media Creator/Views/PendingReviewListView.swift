//
//  PendingReviewListView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData

struct PendingReviewListView: View {
    // Query posts that need review
    @Query private var postsNeedingReview: [Post]
    
    // Environment access to ModelContext for saving changes
    @Environment(\.modelContext) private var modelContext
    
    // State to track post being deleted for confirmation
    @State private var postToDelete: Post?
    @State private var showingDeleteConfirmation = false
    
    // Initialize without using a predicate in the Query
    init() {
        // Create default Query without predicate
        _postsNeedingReview = Query<Post, [Post]>()
    }
    
    // Computed property to filter and sort posts
    private var filteredPosts: [Post] {
        let filtered = postsNeedingReview.filter { post in
            post.status == .pendingReview || post.status == .inRevision
        }
        
        // Sort by creation date (newest first)
        return filtered.sorted { $0.creationDate > $1.creationDate }
    }
    
    var body: some View {
        List {
            if filteredPosts.isEmpty {
                ContentUnavailableView {
                    Label("No Posts to Review", systemImage: "checkmark.circle")
                } description: {
                    Text("Any posts waiting for your review will appear here.")
                }
            } else {
                ForEach(filteredPosts) { post in
                    NavigationLink(destination: PostReviewView(post: post)) {
                        ReviewItemRow(post: post)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            postToDelete = post
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Pending Review")
        .listStyle(.insetGrouped)
        .alert("Delete Post", isPresented: $showingDeleteConfirmation, presenting: postToDelete) { post in
            Button("Cancel", role: .cancel) {
                postToDelete = nil
            }
            Button("Delete", role: .destructive) {
                deletePost(post)
                postToDelete = nil
            }
        } message: { post in
            Text("Are you sure you want to delete the post '\(post.topic)'? This action cannot be undone.")
        }
    }
    
    // Function to delete a post from the model context
    private func deletePost(_ post: Post) {
        modelContext.delete(post)
        
        // Try to save the context changes
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete post: \(error)")
            // In a production app, you might want to show an error to the user
        }
    }
}

// Row for displaying post preview in the list
struct ReviewItemRow: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Platform badge and creation date
            HStack {
                Text(post.platform)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(platformColor(post.platform).opacity(0.2))
                    .foregroundColor(platformColor(post.platform))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(post.creationDate, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Topic
            Text(post.topic)
                .font(.headline)
                .lineLimit(1)
            
            // Content preview
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Status indicator
            HStack {
                Image(systemName: statusIcon(post.status))
                    .foregroundColor(statusColor(post.status))
                
                Text(statusText(post.status))
                    .font(.caption)
                    .foregroundColor(statusColor(post.status))
                
                if post.status == .inRevision {
                    Spacer()
                    Text("Revised")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Return appropriate color for each platform
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
    
    // Return appropriate icon for each status
    private func statusIcon(_ status: PostStatus) -> String {
        switch status {
        case .draft:
            return "doc.fill"
        case .pendingReview:
            return "clock.fill"
        case .inRevision:
            return "arrow.triangle.2.circlepath"
        case .approved:
            return "checkmark.circle.fill"
        case .posted:
            return "checkmark.seal.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }
    
    // Return appropriate color for each status
    private func statusColor(_ status: PostStatus) -> Color {
        switch status {
        case .draft:
            return .gray
        case .pendingReview:
            return .orange
        case .inRevision:
            return .blue
        case .approved:
            return .green
        case .posted:
            return .green
        case .failed:
            return .red
        }
    }
    
    // Return appropriate text for each status
    private func statusText(_ status: PostStatus) -> String {
        switch status {
        case .draft:
            return "Draft"
        case .pendingReview:
            return "Awaiting Review"
        case .inRevision:
            return "In Revision"
        case .approved:
            return "Approved"
        case .posted:
            return "Posted"
        case .failed:
            return "Failed"
        }
    }
}

#Preview {
    NavigationStack {
        PendingReviewListView()
    }
    .modelContainer(for: Post.self, inMemory: true)
}
