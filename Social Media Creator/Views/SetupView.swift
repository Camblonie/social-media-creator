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
    
    // State for form fields
    @State private var companyName: String = ""
    @State private var businessType: String = "Auto Repair"
    @State private var googleDocURL: String = ""
    @State private var googleSheetURL: String = ""
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
                    TextField("Google Doc URL (Instructions)", text: $googleDocURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Google Sheet URL (Post Tracking)", text: $googleSheetURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
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
        
        // Check for existing settings
        if let existingSettings = settings.first {
            // Update existing settings
            existingSettings.companyName = companyName
            existingSettings.businessType = businessType
            existingSettings.googleDocURL = googleDocURL.isEmpty ? nil : googleDocURL
            existingSettings.googleSheetURL = googleSheetURL.isEmpty ? nil : googleSheetURL
            existingSettings.companyLogo = logoData
        } else {
            // Create new settings
            let newSettings = AppSettings(
                googleDocURL: googleDocURL.isEmpty ? nil : googleDocURL,
                googleSheetURL: googleSheetURL.isEmpty ? nil : googleSheetURL,
                companyLogo: logoData,
                companyName: companyName,
                businessType: businessType
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
}

#Preview {
    SetupView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}
