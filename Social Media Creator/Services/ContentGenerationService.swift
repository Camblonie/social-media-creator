//
//  ContentGenerationService.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftUI

// Service to handle AI content generation for social media posts
class ContentGenerationService {
    // Shared instance (singleton)
    static let shared = ContentGenerationService()
    
    // API key for OpenAI (in production, this would be stored securely)
    private var apiKey: String = ""
    
    // OpenAI API endpoints
    private let textCompletionEndpoint = "https://api.openai.com/v1/chat/completions"
    private let imageGenerationEndpoint = "https://api.openai.com/v1/images/generations"
    
    // Initialize with default settings
    private init() {}
    
    // Set the API key
    func configure(withAPIKey key: String) {
        self.apiKey = key
    }
    
    // Generate content for a specific platform based on a topic
    func generateContent(
        for platform: SocialMediaPlatform,
        topic: String,
        recentPosts: [Post],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Prepare the prompt for content generation
        let prompt = prepareContentPrompt(platform: platform, topic: topic, recentPosts: recentPosts)
        
        // Create the request to OpenAI
        createTextCompletionRequest(prompt: prompt, completion: completion)
    }
    
    // Generate an image for a post
    func generateImage(
        for post: Post,
        platform: SocialMediaPlatform,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // Prepare the prompt for image generation
        let prompt = prepareImagePrompt(post: post, platform: platform)
        
        // Create the request to DALL-E
        createImageGenerationRequest(prompt: prompt, completion: completion)
    }
    
    // Refine a post based on user feedback
    func refinePost(
        post: Post,
        feedback: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Prepare the prompt for content refinement
        let prompt = prepareRefinementPrompt(post: post, feedback: feedback)
        
        // Create the request to OpenAI
        createTextCompletionRequest(prompt: prompt, completion: completion)
    }
    
    // Research recent news on a topic
    func researchTopic(
        topic: String,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        // In a real app, this would use a news API or web scraping
        // For this example, we'll simulate with some sample sources
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 1.0)
            
            let sources = [
                "https://www.autoblog.com/automotive-repair-news",
                "https://www.motor1.com/news/automotive-maintenance",
                "https://www.caranddriver.com/repair-maintenance"
            ]
            
            completion(.success(sources))
        }
    }
    
    // MARK: - Private Helper Methods
    
    // Prepare a prompt for content generation
    private func prepareContentPrompt(platform: SocialMediaPlatform, topic: String, recentPosts: [Post]) -> String {
        // In a real implementation, this would be more sophisticated
        return """
        Create a social media post for \(platform.name) about \(topic) for an automotive repair business.
        
        Format requirements for \(platform.name): \(platform.formatRequirements)
        
        Recent posts (avoid similar content):
        \(recentPosts.map { "- \($0.topic): \($0.content.prefix(100))..." }.joined(separator: "\n"))
        
        The post should be educational, engaging, and include a call to action related to automotive repair services.
        """
    }
    
    // Prepare a prompt for image generation
    private func prepareImagePrompt(post: Post, platform: SocialMediaPlatform) -> String {
        // In a real implementation, this would be more sophisticated
        return """
        Create a professional, high-quality image for an automotive repair business social media post about \(post.topic).
        The image should be appropriate for \(platform.name), eye-catching, and relevant to automotive repair.
        Include tools, vehicles, or repair equipment. Ensure the image looks professional and trustworthy.
        """
    }
    
    // Prepare a prompt for content refinement
    private func prepareRefinementPrompt(post: Post, feedback: String) -> String {
        return """
        Original post: \(post.content)
        
        User feedback: \(feedback)
        
        Please refine the post based on this feedback while maintaining the original topic (\(post.topic))
        and ensuring it's still appropriate for \(post.platform).
        """
    }
    
    // Create a request to the OpenAI text completion API
    private func createTextCompletionRequest(
        prompt: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // In a real implementation, this would make an actual API call
        // For this example, we'll simulate the response
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 2.0)
            
            // Sample response based on the prompt
            if prompt.contains("Facebook") {
                completion(.success("🔧 Did you know that regular oil changes can extend your engine's life by up to 50%? Our certified technicians use only premium synthetic oils to keep your vehicle running smoothly. Stop by this week for our special maintenance package and get a free tire rotation with every oil change! #CarMaintenance #AutoTips"))
            } else if prompt.contains("Instagram") {
                completion(.success("Keep your ride running smooth! 🚗✨ Regular maintenance is key to vehicle longevity. Swipe up to see our current service specials and book your appointment today! #AutoRepair #CarCare #MechanicLife"))
            } else if prompt.contains("TikTok") {
                completion(.success("Quick tip: How to check your tire pressure properly! 🔍 Low tire pressure reduces fuel efficiency and causes uneven wear. Let us help you maintain optimal pressure for a smoother ride! #CarTips #AutoRepair #QuickFix"))
            } else if prompt.contains("X") {
                completion(.success("Engine making strange noises? Don't ignore it! Small issues can become major repairs if left unchecked. Our diagnostic services can identify problems early, saving you time and money. Book online today! #AutoRepair #CarMaintenance"))
            } else if prompt.contains("LinkedIn") {
                completion(.success("The automotive repair industry is evolving with new technologies. Our technicians undergo continuous training to stay current with the latest diagnostic tools and repair techniques for modern vehicles. Trust your vehicle to certified professionals who understand both traditional and cutting-edge automotive systems. #ProfessionalDevelopment #AutomotiveTechnology"))
            } else {
                completion(.success("Regular maintenance is the key to extending your vehicle's life and preventing costly repairs. Schedule your service appointment today and let our expert technicians keep your car running at its best!"))
            }
        }
    }
    
    // Create a request to the DALL-E image generation API
    private func createImageGenerationRequest(
        prompt: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // In a real implementation, this would make an actual API call
        // For this example, we'll simulate with a placeholder image
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 3.0)
            
            // Create a placeholder image
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
            let image = renderer.image { ctx in
                UIColor.systemGray6.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: paragraphStyle
                ]
                
                let text = "Generated Image for:\n\(prompt.prefix(100))..."
                text.draw(with: CGRect(x: 20, y: 450, width: 984, height: 200), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }
            
            if let imageData = image.pngData() {
                completion(.success(imageData))
            } else {
                completion(.failure(NSError(domain: "ContentGenerationService", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to create image data"])))
            }
        }
    }
}
