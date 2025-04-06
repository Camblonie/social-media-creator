//
//  GoogleIntegrationService.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftUI

// Service to handle Google Docs and Sheets integration
class GoogleIntegrationService: ObservableObject {
    // Shared instance (singleton)
    static let shared = GoogleIntegrationService()
    
    // Google API client configuration
    private var clientID: String = ""
    private var clientSecret: String = ""
    private var isConfigured: Bool = false
    
    // Authentication state
    @Published var isAuthenticated: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userProfileImage: UIImage?
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    
    // Initialize with default settings
    private init() {
        // Check if user is already authenticated from keychain
        checkSavedAuthentication()
    }
    
    // Configure the service with Google API credentials
    func configure(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.isConfigured = true
    }
    
    // Check for saved authentication
    private func checkSavedAuthentication() {
        // In a production app, this would check keychain for stored tokens
        // For this sample, we'll simulate no saved authentication
        self.isAuthenticated = false
    }
    
    // Sign in with Google
    func signIn(completion: @escaping (Bool, Error?) -> Void) {
        // Reset any previous errors
        self.authError = nil
        self.isAuthenticating = true
        
        // In a real app, this would show the Google Sign In UI and handle the OAuth flow
        // For this example, we'll simulate the authentication process
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 2.0)
            
            DispatchQueue.main.async {
                // Simulate successful login (90% of the time)
                if Bool.random(probability: 0.9) {
                    self.isAuthenticated = true
                    self.userName = "Scott Campbell"
                    self.userEmail = "scott.campbell@example.com"
                    
                    // Generate a simple profile image
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
                    self.userProfileImage = renderer.image { ctx in
                        UIColor.systemBlue.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
                        
                        let initials = "SC"
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.boldSystemFont(ofSize: 40),
                            .foregroundColor: UIColor.white
                        ]
                        let attributedString = NSAttributedString(string: initials, attributes: attributes)
                        let stringSize = attributedString.size()
                        let rect = CGRect(x: (100 - stringSize.width) / 2, y: (100 - stringSize.height) / 2, width: stringSize.width, height: stringSize.height)
                        attributedString.draw(in: rect)
                    }
                    
                    completion(true, nil)
                } else {
                    // Simulate failure
                    let error = NSError(
                        domain: "GoogleIntegrationService",
                        code: 1002,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to authenticate with Google"]
                    )
                    self.authError = error.localizedDescription
                    completion(false, error)
                }
                
                self.isAuthenticating = false
            }
        }
    }
    
    // Sign out
    func signOut() {
        // In a real app, this would revoke tokens and clear OAuth state
        // For this example, we'll just reset our properties
        self.isAuthenticated = false
        self.userName = ""
        self.userEmail = ""
        self.userProfileImage = nil
    }
    
    // Read formatting instructions from a Google Doc
    func readInstructionsFromDoc(docURL: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        // Check if configured
        guard isConfigured else {
            let error = NSError(
                domain: "GoogleIntegrationService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Google API not configured"]
            )
            completion(.failure(error))
            return
        }
        
        // In a real implementation, this would make an actual API call to Google Docs
        // For this example, we'll simulate with sample instructions
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.5)
            
            let instructions: [String: String] = [
                "Facebook": "Posts should be 1-2 paragraphs with an image. Include emojis and hashtags. Best time to post is 1-4pm.",
                "Instagram": "Use high-quality images with short, engaging captions. Include relevant hashtags (5-10). Best time to post is 11am-1pm.",
                "TikTok": "Short, attention-grabbing content focused on quick tips or interesting facts. Best time to post is 9am-11am.",
                "X": "Short, concise messages with a clear call to action. Include hashtags and an image when relevant. Best time to post is 9am-11am.",
                "LinkedIn": "Professional tone with industry insights. Longer form content is acceptable. Best time to post is 8am-10am."
            ]
            
            completion(.success(instructions))
        }
    }
    
    // Check Google Sheet for recent posts to avoid similar topics
    func checkRecentPosts(sheetURL: String, topic: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Check if configured
        guard isConfigured else {
            let error = NSError(
                domain: "GoogleIntegrationService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Google API not configured"]
            )
            completion(.failure(error))
            return
        }
        
        // In a real implementation, this would make an actual API call to Google Sheets
        // For this example, we'll simulate checking for similar topics
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // Simulate checking if the topic is similar to recent posts
            // In a real app, this would compare with actual data from the sheet
            let topicLowercase = topic.lowercased()
            let recentTopics = [
                "oil changes",
                "tire rotation",
                "brake maintenance",
                "air filter replacement",
                "transmission service"
            ]
            
            // Check if any similar topics exist
            let isSimilar = recentTopics.contains { recentTopic in
                topicLowercase.contains(recentTopic) || recentTopic.contains(topicLowercase)
            }
            
            // Return true if the topic is unique (not similar to recent posts)
            completion(.success(!isSimilar))
        }
    }
    
    // Save a post to the Google Sheet after it's published
    func savePostToSheet(sheetURL: String, post: Post, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Check if configured
        guard isConfigured else {
            let error = NSError(
                domain: "GoogleIntegrationService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Google API not configured"]
            )
            completion(.failure(error))
            return
        }
        
        // In a real implementation, this would make an actual API call to Google Sheets
        // For this example, we'll simulate saving the post
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // In a real app, this would actually save the data to a Google Sheet
            // For now, just simulate success
            completion(.success(true))
        }
    }
    
    // Get a list of recent posts from the Google Sheet
    func getRecentPosts(sheetURL: String, platform: String, limit: Int = 10, completion: @escaping (Result<[PostSummary], Error>) -> Void) {
        // Check if configured
        guard isConfigured else {
            let error = NSError(
                domain: "GoogleIntegrationService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Google API not configured"]
            )
            completion(.failure(error))
            return
        }
        
        // In a real implementation, this would make an actual API call to Google Sheets
        // For this example, we'll simulate with sample data
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.5)
            
            // Sample post summaries
            let summaries = [
                PostSummary(platform: platform, topic: "Oil Change Tips", postDate: Date().addingTimeInterval(-7 * 86400)),
                PostSummary(platform: platform, topic: "Tire Maintenance", postDate: Date().addingTimeInterval(-14 * 86400)),
                PostSummary(platform: platform, topic: "Check Engine Light", postDate: Date().addingTimeInterval(-21 * 86400)),
                PostSummary(platform: platform, topic: "Winter Car Care", postDate: Date().addingTimeInterval(-28 * 86400))
            ]
            
            completion(.success(summaries))
        }
    }
}

// Simple struct to represent a post summary from the sheet
struct PostSummary {
    let platform: String
    let topic: String
    let postDate: Date
}

// Extension for random bool with probability
extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
