//
//  OpenAIIntegrationService.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftUI

// Service to handle OpenAI integration for DALL-E image generation
class OpenAIIntegrationService: ObservableObject {
    // Shared instance (singleton)
    static let shared = OpenAIIntegrationService()
    
    // OpenAI API key storage
    @Published var apiKey: String = ""
    
    // Authentication state
    @Published var isAuthenticated: Bool = false
    @Published var accountEmail: String = ""
    @Published var isAuthenticating: Bool = false
    @Published var authError: String?
    @Published var usageTier: String = ""
    @Published var lastGeneratedImage: UIImage?
    
    // Initialize with default settings
    private init() {
        // Check if user is already authenticated from keychain
        checkSavedAuthentication()
    }
    
    // Check for saved authentication
    private func checkSavedAuthentication() {
        // In a production app, this would check keychain for stored API key
        // For this sample, we'll simulate no saved authentication
        self.isAuthenticated = false
    }
    
    // Authenticate with OpenAI
    func authenticate(apiKey: String, completion: @escaping (Bool, Error?) -> Void) {
        // Reset any previous errors
        self.authError = nil
        self.isAuthenticating = true
        
        // In a real app, this would validate the API key against the OpenAI API
        // For this example, we'll simulate the authentication process
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1.5)
            
            DispatchQueue.main.async {
                // Simulate successful authentication (95% of the time)
                if apiKey.count >= 8 && Bool.random(probability: 0.95) {
                    self.isAuthenticated = true
                    self.apiKey = apiKey
                    self.accountEmail = "scott.campbell@example.com" // In a real app, this would come from the OpenAI API
                    self.usageTier = "ChatGPT Plus"
                    
                    // Generate a placeholder image
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
                    self.lastGeneratedImage = renderer.image { ctx in
                        UIColor.systemGreen.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
                        
                        let logo = "AI"
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.boldSystemFont(ofSize: 40),
                            .foregroundColor: UIColor.white
                        ]
                        let attributedString = NSAttributedString(string: logo, attributes: attributes)
                        let stringSize = attributedString.size()
                        let rect = CGRect(x: (100 - stringSize.width) / 2, y: (100 - stringSize.height) / 2, width: stringSize.width, height: stringSize.height)
                        attributedString.draw(in: rect)
                    }
                    
                    completion(true, nil)
                } else {
                    // Simulate failure
                    let error = NSError(
                        domain: "OpenAIIntegrationService",
                        code: 1003,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid API key or authentication failed"]
                    )
                    self.authError = error.localizedDescription
                    completion(false, error)
                }
                
                self.isAuthenticating = false
            }
        }
    }
    
    // Sign out / disconnect
    func signOut() {
        // In a real app, this would revoke or clear the API key from secure storage
        self.isAuthenticated = false
        self.apiKey = ""
        self.accountEmail = ""
        self.usageTier = ""
        self.lastGeneratedImage = nil
    }
    
    // Generate an image with DALL-E
    func generateImage(prompt: String, completion: @escaping (UIImage?, Error?) -> Void) {
        // Check if authenticated with a valid API key
        guard isAuthenticated, !apiKey.isEmpty else {
            let error = NSError(
                domain: "OpenAIIntegrationService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated with OpenAI"]
            )
            completion(nil, error)
            return
        }
        
        // In a real implementation, this would make an API call to OpenAI's DALL-E endpoint
        // For this example, we'll simulate generating an image
        DispatchQueue.global().async {
            // Simulate API delay
            Thread.sleep(forTimeInterval: 3.0)
            
            DispatchQueue.main.async {
                // Generate a placeholder image based on the prompt
                let colors: [UIColor] = [.systemBlue, .systemGreen, .systemPurple, .systemOrange, .systemPink]
                let randomColor = colors.randomElement() ?? .systemBlue
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
                let generatedImage = renderer.image { ctx in
                    randomColor.setFill()
                    ctx.fill(CGRect(x: 0, y: 0, width: 300, height: 300))
                    
                    // Draw a simple pattern
                    for i in 0..<5 {
                        for j in 0..<5 {
                            if (i + j) % 2 == 0 {
                                UIColor.white.withAlphaComponent(0.3).setFill()
                                ctx.fill(CGRect(x: i * 60, y: j * 60, width: 30, height: 30))
                            }
                        }
                    }
                    
                    // Draw a portion of the prompt
                    let shortPrompt = prompt.count > 20 ? String(prompt.prefix(20)) + "..." : prompt
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 18),
                        .foregroundColor: UIColor.white
                    ]
                    let attributedString = NSAttributedString(string: shortPrompt, attributes: attributes)
                    let stringSize = attributedString.size()
                    let rect = CGRect(x: (300 - stringSize.width) / 2, y: 270 - stringSize.height, width: stringSize.width, height: stringSize.height)
                    attributedString.draw(in: rect)
                }
                
                self.lastGeneratedImage = generatedImage
                completion(generatedImage, nil)
            }
        }
    }
}
