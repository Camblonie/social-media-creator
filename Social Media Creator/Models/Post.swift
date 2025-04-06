//
//  Post.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftData

// Represents a social media post with content and metadata
@Model
final class Post {
    // Basic post information
    var id: UUID                    // Unique identifier
    var topic: String               // Topic of the post
    var content: String             // Content/text of the post
    var imageURL: URL?              // URL to the generated or uploaded image
    var imageData: Data?            // Image data if stored locally
    var platform: String            // Platform name this post is for
    var creationDate: Date          // When the post was created
    var postDate: Date?             // When the post was published (if it was)
    var status: PostStatus          // Current status of the post
    var userFeedback: String?       // Feedback from the user during review
    var sourceURLs: [String]        // Source URLs used for research
    
    // Reference to the parent platform
    var targetPlatformID: String?   // Store platform ID instead of relationship
    
    // Initialize a new post
    init(
        id: UUID = UUID(),
        topic: String,
        content: String,
        imageURL: URL? = nil,
        imageData: Data? = nil,
        platform: String,
        creationDate: Date = Date(),
        postDate: Date? = nil,
        status: PostStatus = .draft,
        userFeedback: String? = nil,
        sourceURLs: [String] = [],
        targetPlatformID: String? = nil
    ) {
        self.id = id
        self.topic = topic
        self.content = content
        self.imageURL = imageURL
        self.imageData = imageData
        self.platform = platform
        self.creationDate = creationDate
        self.postDate = postDate
        self.status = status
        self.userFeedback = userFeedback
        self.sourceURLs = sourceURLs
        self.targetPlatformID = targetPlatformID
    }
}

// Status of a post through its lifecycle
enum PostStatus: String, Codable {
    case draft          // Initial draft
    case pendingReview  // Waiting for user review
    case inRevision     // Being revised based on feedback
    case approved       // Approved but not yet posted
    case posted         // Successfully posted
    case failed         // Failed to post
}
