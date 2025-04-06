//
//  SetupView.swift
//  Social Media Creator
//
//  Created by Scott Campbell on 4/6/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct SetupView: View {
    // Environment for accessing the model context
    @Environment(\.modelContext) private var modelContext
    
    // Settings from the database
    @Query private var settings: [AppSettings]
    
    // Google Integration Service
    @StateObject private var googleService = GoogleIntegrationService.shared
    
    // OpenAI Integration Service
    @StateObject private var openAIService = OpenAIIntegrationService.shared
    
    // State for form fields
    @State private var companyName: String = ""
    @State private var businessType: String = "Auto Repair"
    @State private var googleDocURL: String = ""
    @State private var googleSheetURL: String = ""
    @State private var openAIApiKey: String = ""
    @State private var selectedLogo: PhotosPickerItem?
    @State private var logoData: Data?
    
    // State for showing alerts
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Business types for the picker
    private let businessTypes = [
        "Auto Repair", "Auto Body", "Car Dealership", "Tire Shop", 
        "Oil Change Service", "Auto Parts Store", "Auto Detailing"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Business Information")) {
                    TextField("Company Name", text: $companyName)
                        .autocapitalization(.words)
                    
                    Picker("Business Type", selection: $businessType) {
                        ForEach(businessTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    HStack {
                        Text("Company Logo")
                        Spacer()
                        PhotosPicker(selection: $selectedLogo, matching: .images) {
                            if let logoData, let uiImage = UIImage(data: logoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Label("Select Logo", systemImage: "photo.badge.plus")
                            }
                        }
                    }
                }
                
                Section(header: Text("Google Integration")) {
                    if googleService.isAuthenticated {
                        // Show authenticated user
                        HStack(spacing: 12) {
                            if let profileImage = googleService.userProfileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(googleService.userName)
                                    .font(.headline)
                                Text(googleService.userEmail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Sign Out") {
                                googleService.signOut()
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.vertical, 6)
                        
                        Text("Connected to Google")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.bottom, 4)
                        
                    } else {
                        // Show sign-in prompt
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Connect with Google")
                                .font(.headline)
                            
                            Text("Sign in to your Google account to access your Docs and Sheets for content management")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: signInWithGoogle) {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .font(.headline)
                                    Text(googleService.isAuthenticating ? "Signing in..." : "Sign in with Google")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(googleService.isAuthenticating)
                            .padding(.top, 4)
                            
                            if let error = googleService.authError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    TextField("Google Doc URL (Instructions)", text: $googleDocURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(!googleService.isAuthenticated)
                    
                    TextField("Google Sheet URL (Post Tracking)", text: $googleSheetURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(!googleService.isAuthenticated)
                    
                    if !googleService.isAuthenticated {
                        Text("Sign in to Google to use Docs and Sheets integration")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                    }
                }
                
                Section(header: Text("OpenAI Integration for DALL-E")) {
                    if openAIService.isAuthenticated {
                        // Show authenticated user
                        HStack(spacing: 12) {
                            if let lastImage = openAIService.lastGeneratedImage {
                                Image(uiImage: lastImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "sparkles.square.filled.on.square")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(openAIService.accountEmail)
                                    .font(.headline)
                                Text(openAIService.usageTier)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Disconnect") {
                                openAIService.signOut()
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.vertical, 6)
                        
                        Text("Connected to OpenAI")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.bottom, 4)
                        
                        Text("Your account is now set up for DALL-E image generation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    
                    } else {
                        // Show sign-in prompt
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Connect to OpenAI for DALL-E")
                                .font(.headline)
                            
                            Text("Add your OpenAI API key to enable AI-powered image generation for your social media posts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            SecureField("OpenAI API Key", text: $openAIApiKey)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .padding(.vertical, 6)
                            
                            Button(action: authenticateWithOpenAI) {
                                HStack {
                                    Image(systemName: "sparkles.rectangle.stack")
                                        .font(.headline)
                                    Text(openAIService.isAuthenticating ? "Connecting..." : "Connect to OpenAI")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(openAIApiKey.isEmpty || openAIService.isAuthenticating)
                            .padding(.top, 4)
                            
                            if let error = openAIService.authError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }
                            
                            Text("Don't have an API key? Visit [OpenAI's website](https://platform.openai.com) to get one.")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            Text("Save Settings")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("App Setup")
            .onAppear(perform: loadExistingSettings)
            .onChange(of: selectedLogo) { loadSelectedLogo() }
            .alert("Settings Saved", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // Load existing settings if available
    private func loadExistingSettings() {
        if let existingSettings = settings.first {
            companyName = existingSettings.companyName
            businessType = existingSettings.businessType
            googleDocURL = existingSettings.googleDocURL ?? ""
            googleSheetURL = existingSettings.googleSheetURL ?? ""
            logoData = existingSettings.companyLogo
        }
    }
    
    // Load selected logo from PhotosPicker
    private func loadSelectedLogo() {
        guard let selectedItem = selectedLogo else { return }
        
        selectedItem.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    DispatchQueue.main.async {
                        self.logoData = data
                    }
                }
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    // Save settings to the database
    private func saveSettings() {
        // Validate inputs
        guard !companyName.isEmpty else {
            errorMessage = "Please enter your company name"
            showingErrorAlert = true
            return
        }
        
        // If Google URLs are provided, ensure the user is authenticated
        if (!googleDocURL.isEmpty || !googleSheetURL.isEmpty) && !googleService.isAuthenticated {
            errorMessage = "You must sign in to Google to use Docs and Sheets integration"
            showingErrorAlert = true
            return
        }
        
        // Ensure OpenAI API key is provided if connected
        if !openAIService.isAuthenticated && !openAIApiKey.isEmpty {
            errorMessage = "Please connect to OpenAI before saving your API key"
            showingErrorAlert = true
            return
        }
        
        // Check for existing settings
        if let existingSettings = settings.first {
            // Update existing settings
            existingSettings.companyName = companyName
            existingSettings.businessType = businessType
            existingSettings.googleDocURL = googleDocURL.isEmpty ? nil : googleDocURL
            existingSettings.googleSheetURL = googleSheetURL.isEmpty ? nil : googleSheetURL
            existingSettings.companyLogo = logoData
            existingSettings.openAIConnected = openAIService.isAuthenticated
        } else {
            // Create new settings
            let newSettings = AppSettings(
                googleDocURL: googleDocURL.isEmpty ? nil : googleDocURL,
                googleSheetURL: googleSheetURL.isEmpty ? nil : googleSheetURL,
                activeDays: [.monday, .wednesday, .friday],
                dailyTopics: [:],
                defaultTopic: "Automotive maintenance tips",
                companyLogo: logoData,
                companyName: companyName,
                businessType: businessType,
                openAIConnected: openAIService.isAuthenticated
            )
            
            modelContext.insert(newSettings)
        }
        
        // Try to save the model context
        do {
            try modelContext.save()
            showingSuccessAlert = true
        } catch {
            errorMessage = "Failed to save settings: \(error.localizedDescription)"
            showingErrorAlert = true
        }
    }
    
    // Sign in with Google
    private func signInWithGoogle() {
        googleService.signIn { success, error in
            if !success {
                errorMessage = "Failed to sign in to Google: \(error?.localizedDescription ?? "Unknown error")"
                showingErrorAlert = true
            }
        }
    }
    
    // Authenticate with OpenAI
    private func authenticateWithOpenAI() {
        guard !openAIApiKey.isEmpty else { return }
        
        openAIService.authenticate(apiKey: openAIApiKey) { success, error in
            if !success {
                errorMessage = "Failed to authenticate with OpenAI: \(error?.localizedDescription ?? "Unknown error")"
                showingErrorAlert = true
                openAIApiKey = "" // Clear for security
            }
        }
    }
}

#Preview {
    SetupView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
