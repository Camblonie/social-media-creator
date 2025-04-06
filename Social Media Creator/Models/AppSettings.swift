//
//  AppSettings.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import Foundation
import SwiftData

// Represents app settings and user preferences
@Model
final class AppSettings {
    // Google integration
    var googleDocURL: String?        // URL to the Google Doc with instructions
    var googleSheetURL: String?      // URL to the Google Sheet for tracking posts
    
    // OpenAI integration
    var openAIConnected: Bool = false // Whether OpenAI is connected for DALL-E image generation
    
    // Schedule settings
    var activeDays: [Weekday]        // Days of the week to post
    var dailyTopics: [String: String] // Topics for each day (day name -> topic)
    var defaultTopic: String         // Default topic if none specified
    
    // Customization
    var companyLogo: Data?           // Company logo to overlay on images
    var companyName: String          // Company name
    var businessType: String         // Type of automotive business
    
    // Initialize with default settings
    init(
        googleDocURL: String? = nil,
        googleSheetURL: String? = nil,
        activeDays: [Weekday] = [.monday, .wednesday, .friday],
        dailyTopics: [String: String] = [:],
        defaultTopic: String = "Automotive maintenance tips",
        companyLogo: Data? = nil,
        companyName: String = "Automotive Repair Shop",
        businessType: String = "Auto Repair",
        openAIConnected: Bool = false
    ) {
        self.googleDocURL = googleDocURL
        self.googleSheetURL = googleSheetURL
        self.activeDays = activeDays
        self.dailyTopics = dailyTopics
        self.defaultTopic = defaultTopic
        self.companyLogo = companyLogo
        self.companyName = companyName
        self.businessType = businessType
        self.openAIConnected = openAIConnected
    }
    
    // Get today's topic based on the day of the week
    func getTodayTopic() -> String {
        let today = Calendar.current.component(.weekday, from: Date())
        let weekdayName = Weekday.fromCalendarWeekday(today)?.rawValue
        
        if let weekdayName = weekdayName,
           let topic = dailyTopics[weekdayName],
           !topic.isEmpty {
            return topic
        }
        
        return defaultTopic
    }
    
    // Get topic for a specific day
    func getTopic(for weekday: Weekday) -> String {
        return dailyTopics[weekday.rawValue] ?? defaultTopic
    }
}

// Days of the week enum
enum Weekday: String, Codable, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    // Convert from Calendar.weekday to Weekday
    static func fromCalendarWeekday(_ weekday: Int) -> Weekday? {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
