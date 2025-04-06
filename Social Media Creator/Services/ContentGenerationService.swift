//
//  ContentGenerationService.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftUI
import OpenAI

// Service to handle AI content generation for social media posts
class ContentGenerationService {
    // Shared instance (singleton)
    static let shared = ContentGenerationService()
    
    // OpenAI client
    private var openAI: OpenAI?
    
    // OpenAI API endpoints
    private let textCompletionEndpoint = "https://api.openai.com/v1/chat/completions"
    private let imageGenerationEndpoint = "https://api.openai.com/v1/images/generations"
    
    // Initialize with default settings
    private init() {
        // Check if there's an API key from OpenAIIntegrationService
        let apiKey = OpenAIIntegrationService.shared.apiKey
        if !apiKey.isEmpty {
            configure(withAPIKey: apiKey)
        }
    }
    
    // Set the API key
    func configure(withAPIKey key: String) {
        // Initialize the OpenAI client with the API key
        self.openAI = OpenAI(apiToken: key)
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
        
        // Check if OpenAI client is initialized
        if openAI != nil {
            // Create a chat query to OpenAI
            let query = ChatQuery(
                messages: [
                    .init(role: .system, content: "You are a professional social media content creator specializing in automotive repair business marketing.")!,
                    .init(role: .user, content: prompt)!
                ],
                model: "gpt-4-turbo",
                maxTokens: 500,
                temperature: 0.7
            )
            
            // Call the OpenAI API
            _ = openAI?.chats(query: query) { result in
                switch result {
                case .success(let response):
                    if let content = response.choices.first?.message.content {
                        completion(.success(content))
                    } else {
                        completion(.failure(NSError(domain: "ContentGenerationService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No content returned from OpenAI"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Fall back to simulation if no API key is available
            createSimulatedTextCompletion(prompt: prompt, completion: completion)
        }
    }
    
    // Generate an image for a post
    func generateImage(
        for post: Post,
        platform: SocialMediaPlatform,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // Prepare the prompt for image generation
        let prompt = prepareImagePrompt(post: post, platform: platform)
        
        // Check if OpenAI client is initialized
        if openAI != nil {
            // Create an image generation query
            let query = ImagesQuery(
                prompt: prompt,
                model: "dall-e-3",
                n: 1,
                quality: .standard,
                size: ImagesQuery.Size._1024
            )
            
            // Call the OpenAI API
            _ = openAI?.images(query: query) { result in
                switch result {
                case .success(let response):
                    if let imageUrl = response.data.first?.url {
                        // Download the image data
                        self.downloadImage(from: imageUrl) { imageDataResult in
                            switch imageDataResult {
                            case .success(let data):
                                completion(.success(data))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        completion(.failure(NSError(domain: "ContentGenerationService", code: 1003, userInfo: [NSLocalizedDescriptionKey: "No image URL returned from OpenAI"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Fall back to simulation if no API key is available
            createSimulatedImageGeneration(prompt: prompt, completion: completion)
        }
    }
    
    // Refine a post based on user feedback
    func refinePost(
        post: Post,
        feedback: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Prepare the prompt for content refinement
        let prompt = prepareRefinementPrompt(post: post, feedback: feedback)
        
        // Check if OpenAI client is initialized
        if openAI != nil {
            // Create a chat query for refinement
            let query = ChatQuery(
                messages: [
                    .init(role: .system, content: "You are a professional social media content creator. Refine the post based on the user's feedback.")!,
                    .init(role: .user, content: prompt)!
                ],
                model: "gpt-4-turbo",
                maxTokens: 500,
                temperature: 0.5
            )
            
            // Call the OpenAI API
            _ = openAI?.chats(query: query) { result in
                switch result {
                case .success(let response):
                    if let content = response.choices.first?.message.content {
                        completion(.success(content))
                    } else {
                        completion(.failure(NSError(domain: "ContentGenerationService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No content returned from OpenAI"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Fall back to simulation if no API key is available
            createSimulatedTextCompletion(prompt: prompt, completion: completion)
        }
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
    
    // MARK: - Helper Methods for OpenAI API Integration
    
    // Download image from URL
    private func downloadImage(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ContentGenerationService", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "ContentGenerationService", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "ContentGenerationService", code: 1005, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Simulation methods (fallbacks when API is unavailable)
    
    // Create a simulated text completion when OpenAI is unavailable
    private func createSimulatedTextCompletion(
        prompt: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // This is a fallback when the OpenAI client isn't configured
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
    
    // Create a simulated image generation when OpenAI is unavailable
    private func createSimulatedImageGeneration(
        prompt: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // This is a fallback when the OpenAI client isn't configured
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
