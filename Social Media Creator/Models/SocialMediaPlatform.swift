//
//  SocialMediaPlatform.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftData

// Represents a social media platform with its specific settings and requirements
@Model
final class SocialMediaPlatform {
    @Attribute(.unique) var id: String = UUID().uuidString // Unique identifier
    var name: String               // Platform name (Facebook, Instagram, etc.)
    var isActive: Bool             // Whether posts should be created for this platform
    var lastPostDate: Date?        // Date of the last post on this platform
    var formatRequirements: String // Specific formatting requirements for this platform
    var apiCredentials: String?    // API credentials for posting (would be encrypted in production)
    
    // Initialize a new social media platform
    init(id: String = UUID().uuidString, name: String, isActive: Bool = false, lastPostDate: Date? = nil, formatRequirements: String = "", apiCredentials: String? = nil) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.lastPostDate = lastPostDate
        self.formatRequirements = formatRequirements
        self.apiCredentials = apiCredentials
    }
    
    // Get posts for this platform programmatically instead of through a relationship
    func getPosts(modelContext: ModelContext) -> [Post] {
        // To fix the predicate issue, we need to be more careful with optionals
        do {
            // First, fetch all posts
            let allPosts = try modelContext.fetch(FetchDescriptor<Post>())
            
            // Then filter the posts manually
            return allPosts.filter { post in
                return post.targetPlatformID == self.id
            }
        } catch {
            print("Failed to fetch posts: \(error)")
            return []
        }
    }
    
    // Static function to get the default platforms
    static func defaultPlatforms() -> [SocialMediaPlatform] {
        return [
            SocialMediaPlatform(name: "Facebook", formatRequirements: "Text-focused with single image, best time to post is 1-4pm"),
            SocialMediaPlatform(name: "Instagram", formatRequirements: "Image-focused with caption, best time to post is 11am-1pm"),
            SocialMediaPlatform(name: "TikTok", formatRequirements: "Short-form video content, best time to post is 9am-11am"),
            SocialMediaPlatform(name: "X", formatRequirements: "Short text with possible image, best time to post is 9am-11am"),
            SocialMediaPlatform(name: "LinkedIn", formatRequirements: "Professional content with detailed text, best time to post is 8am-10am")
        ]
    }
}
