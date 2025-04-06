//
//  SocialMediaPostingService.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import UIKit
import SwiftData

// Service to handle posting to social media platforms
class SocialMediaPostingService {
    // Shared instance (singleton)
    static let shared = SocialMediaPostingService()
    
    // Dependencies
    private let googleService = GoogleIntegrationService.shared
    
    // Initialize with default settings
    private init() {}
    
    // Post content to a social media platform
    func postToSocialMedia(post: Post, modelContext: ModelContext, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Get platform from platform ID
        guard let platformID = post.targetPlatformID,
              let platform = try? getPlatform(withID: platformID, in: modelContext) else {
            let error = NSError(
                domain: "SocialMediaPostingService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "No platform specified for post"]
            )
            completion(.failure(error))
            return
        }
        
        // Check if the platform is configured for posting
        guard platform.isActive, platform.apiCredentials != nil else {
            let error = NSError(
                domain: "SocialMediaPostingService",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Platform \(platform.name) is not active or not configured"]
            )
            completion(.failure(error))
            return
        }
        
        // In a real implementation, this would use platform-specific APIs
        // For this example, we'll simulate posting to the platform
        sendPostToPlatform(post: post, platform: platform) { result in
            switch result {
            case .success(let success):
                if success {
                    // Update post status
                    DispatchQueue.main.async {
                        post.status = .posted
                        post.postDate = Date()
                        
                        // Update platform last post date
                        platform.lastPostDate = Date()
                        
                        // Save changes to the model context
                        try? modelContext.save()
                        
                        // Save to Google Sheet for tracking
                        if let settings = try? modelContext.fetch(FetchDescriptor<AppSettings>()).first,
                           let sheetURL = settings.googleSheetURL {
                            self.saveToGoogleSheet(post: post, sheetURL: sheetURL) { _ in
                                // No additional action needed here
                            }
                        }
                    }
                    
                    completion(.success(true))
                } else {
                    // Update post status to failed
                    DispatchQueue.main.async {
                        post.status = .failed
                        try? modelContext.save()
                    }
                    
                    let error = NSError(
                        domain: "SocialMediaPostingService",
                        code: 1003,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to post to \(platform.name)"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                // Update post status to failed
                DispatchQueue.main.async {
                    post.status = .failed
                    try? modelContext.save()
                }
                
                completion(.failure(error))
            }
        }
    }
    
    // Post all approved posts
    func postAllApproved(modelContext: ModelContext, completion: @escaping (Result<Int, Error>) -> Void) {
        // Fetch all posts and filter them manually instead of using a predicate
        do {
            let allPosts = try modelContext.fetch(FetchDescriptor<Post>())
            let approvedPosts = allPosts.filter { post in
                post.status == .approved
            }
            
            guard !approvedPosts.isEmpty else {
                completion(.success(0))
                return
            }
            
            var successCount = 0
            let group = DispatchGroup()
            
            for post in approvedPosts {
                group.enter()
                
                postToSocialMedia(post: post, modelContext: modelContext) { result in
                    switch result {
                    case .success:
                        successCount += 1
                    case .failure:
                        // Individual failures are handled within postToSocialMedia
                        break
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(successCount))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Private Helper Methods
    
    // Helper to get a platform by ID
    private func getPlatform(withID id: String, in modelContext: ModelContext) throws -> SocialMediaPlatform? {
        // To fix predicate issues, fetch all platforms and filter manually
        let allPlatforms = try modelContext.fetch(FetchDescriptor<SocialMediaPlatform>())
        return allPlatforms.first { platform in
            platform.id == id
        }
    }
    
    // Send a post to a specific platform
    private func sendPostToPlatform(post: Post, platform: SocialMediaPlatform, completion: @escaping (Result<Bool, Error>) -> Void) {
        // In a real implementation, this would use platform-specific APIs
        // For this example, we'll simulate sending to different platforms
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 2.0)
            
            // Simulate a 90% success rate
            let isSuccessful = Double.random(in: 0...1) < 0.9
            
            if isSuccessful {
                completion(.success(true))
            } else {
                let error = NSError(
                    domain: "SocialMediaPostingService",
                    code: 1004,
                    userInfo: [NSLocalizedDescriptionKey: "Network error when posting to \(platform.name)"]
                )
                completion(.failure(error))
            }
        }
    }
    
    // Save a posted content to Google Sheet for tracking
    private func saveToGoogleSheet(post: Post, sheetURL: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        googleService.savePostToSheet(sheetURL: sheetURL, post: post, completion: completion)
    }
}
