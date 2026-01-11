//
//  EntriesViewModel.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/16/25.
//

import SwiftUI
import Amplify
internal import AWSPluginsCore
import AWSS3StoragePlugin
import AWSCognitoAuthPlugin
import UIKit

@Observable
class EntriesViewModel {
    var entries: [Entry] = []
    var categories: [Category] = []
    var properties: [Property] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Fetch Categories
    
    @MainActor
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = GraphQLRequest<Category>.list(Category.self)
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let categoryList):
                categories = categoryList.elements
                print("✅ Fetched \(categories.count) categories")
                
                // If no categories exist, create default ones
                if categories.isEmpty {
                    print("📝 No categories found, creating default categories...")
                    await createDefaultCategories()
                    // Fetch again to get the newly created categories
                    await fetchCategories()
                    return
                }
            case .failure(let error):
                let errorDescription = String(describing: error)
                errorMessage = "Failed to fetch categories: \(errorDescription)"
                print("❌ Error fetching categories: \(error)")
            }
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to fetch categories: \(errorDescription)"
            print("❌ Error fetching categories: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Default Categories
    
    @MainActor
    private func createDefaultCategories() async {
        let defaultCategories = [
            "Administrative",
            "Tenant Communication",
            "Property Maintenance",
            "Property Improvements"
        ]
        
        print("🔄 Creating \(defaultCategories.count) default categories...")
        
        for categoryName in defaultCategories {
            do {
                let document = """
                mutation CreateCategory($input: CreateCategoryInput!) {
                  createCategory(input: $input) {
                    id
                    name
                    createdAt
                    updatedAt
                  }
                }
                """
                
                let input: [String: Any] = ["name": categoryName]
                
                let request = GraphQLRequest<String>(
                    document: document,
                    variables: ["input": input],
                    responseType: String.self,
                    decodePath: "createCategory"
                )
                
                _ = try await Amplify.API.mutate(request: request)
                print("✅ Created category: \(categoryName)")
            } catch {
                print("❌ Error creating category '\(categoryName)': \(error)")
            }
        }
        
        print("✅ Finished creating default categories")
    }
    
    // MARK: - Fetch Properties
    
    @MainActor
    func fetchProperties() async {
        isLoading = true
        errorMessage = nil
        
        print("🔍 EntriesViewModel: Starting to fetch properties...")
        
        do {
            let request = GraphQLRequest<Property>.list(Property.self)
            print("🔍 EntriesViewModel: Created GraphQL request")
            
            let result = try await Amplify.API.query(request: request)
            print("🔍 EntriesViewModel: Received query result")
            
            switch result {
            case .success(let propertyList):
                properties = propertyList.elements
                print("✅ EntriesViewModel: Successfully fetched \(properties.count) properties")
                if properties.isEmpty {
                    print("⚠️ EntriesViewModel: Property list is EMPTY even though query succeeded")
                } else {
                    print("📋 EntriesViewModel: Properties: \(properties.map { $0.name })")
                }
            case .failure(let error):
                let errorDescription = String(describing: error)
                errorMessage = "Failed to fetch properties: \(errorDescription)"
                print("❌ EntriesViewModel: GraphQL query failed: \(error)")
            }
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to fetch properties: \(errorDescription)"
            print("❌ EntriesViewModel: Exception while fetching properties: \(error)")
        }
        
        isLoading = false
        print("🏁 EntriesViewModel: Fetch properties completed. Final count: \(properties.count)")
    }
    
    // MARK: - Fetch Entries
    
    @MainActor
    func fetchEntries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = GraphQLRequest<Entry>.list(Entry.self)
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let entryList):
                entries = entryList.elements
                print("✅ Fetched \(entries.count) entries")
            case .failure(let error):
                let errorDescription = String(describing: error)
                errorMessage = "Failed to fetch entries: \(errorDescription)"
                print("❌ Error fetching entries: \(error)")
            }
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to fetch entries: \(errorDescription)"
            print("❌ Error fetching entries: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Add Entry
    
    @MainActor
    func addEntry(
        propertyID: String,
        categoryID: String?,
        date: Date,
        hours: Int,
        minutes: Int,
        performer: String,
        activityType: String,
        notes: String?,
        images: [UIImage] = []
    ) async throws -> String {
        // Calculate total minutes
        let totalMinutes = (hours * 60) + minutes
        
        // Convert Date to Temporal.Date using ISO8601 date string format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        
        guard let temporalDate = try? Temporal.Date(iso8601String: dateString) else {
            throw NSError(domain: "EntriesViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }
        
        // Verify property exists
        guard properties.first(where: { $0.id == propertyID }) != nil else {
            throw NSError(domain: "EntriesViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Property not found"])
        }
        
        print("🔄 Creating entry with property: \(propertyID), category: \(categoryID ?? "none")")
        
        // Build GraphQL input - use the exact field names from schema.ts
        var input: [String: Any] = [
            "date": dateString,
            "totalMinutes": totalMinutes,
            "performer": performer,
            "activityType": activityType,
            "propertyID": propertyID
        ]
        
        if let notes = notes, !notes.isEmpty {
            input["notes"] = notes
        }
        
        if let catID = categoryID {
            input["categoryID"] = catID
        }
        
        // Create the GraphQL mutation manually
        let document = """
        mutation CreateEntry($input: CreateEntryInput!) {
          createEntry(input: $input) {
            id
            date
            totalMinutes
            performer
            activityType
            notes
            propertyID
            categoryID
            images
            createdAt
            updatedAt
          }
        }
        """
        
        do {
            let request = GraphQLRequest<String>(
                document: document,
                variables: ["input": input],
                responseType: String.self,
                decodePath: "createEntry"
            )
            
            let result = try await Amplify.API.mutate(request: request)
            
            // Extract entry ID from response
            switch result {
            case .success(let resultString):
                guard let jsonData = resultString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                      let entryID = json["id"] as? String else {
                    throw NSError(domain: "EntriesViewModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not extract entry ID"])
                }
                
                print("✅ Entry created successfully with ID: \(entryID)")
                
                // Upload images if any
                if !images.isEmpty {
                    print("📤 Uploading \(images.count) images...")
                    let imageKeys = try await uploadImages(images, entryID: entryID)
                    
                    // Update entry with image URLs
                    try await updateEntryImages(entryID: entryID, imageKeys: imageKeys)
                }
                
                // Refresh entries list
                await fetchEntries()
                
                return entryID
                
            case .failure(let error):
                print("❌ Error creating entry: \(error)")
                throw error
            }
        } catch {
            print("❌ Error creating entry: \(error)")
            print("❌ Error details: \(String(describing: error))")
            throw error
        }
    }
    
    @MainActor
    private func updateEntryImages(entryID: String, imageKeys: [String]) async throws {
        let document = """
        mutation UpdateEntry($input: UpdateEntryInput!) {
          updateEntry(input: $input) {
            id
            images
          }
        }
        """
        
        let input: [String: Any] = [
            "id": entryID,
            "images": imageKeys
        ]
        
        let request = GraphQLRequest<String>(
            document: document,
            variables: ["input": input],
            responseType: String.self,
            decodePath: "updateEntry"
        )
        
        _ = try await Amplify.API.mutate(request: request)
        print("✅ Entry images updated successfully")
    }
    
    // MARK: - Update Entry
    
    @MainActor
    func updateEntry(
        entryID: String,
        propertyID: String,
        categoryID: String?,
        date: Date,
        hours: Int,
        minutes: Int,
        performer: String,
        activityType: String,
        notes: String?,
        newImages: [UIImage] = [],
        existingImageKeys: [String] = []
    ) async throws {
        // Calculate total minutes
        let totalMinutes = (hours * 60) + minutes
        
        // Convert Date to Temporal.Date using ISO8601 date string format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        
        print("🔄 Updating entry \(entryID)")
        
        // Build GraphQL input
        var input: [String: Any] = [
            "id": entryID,
            "date": dateString,
            "totalMinutes": totalMinutes,
            "performer": performer,
            "activityType": activityType,
            "propertyID": propertyID
        ]
        
        if let notes = notes, !notes.isEmpty {
            input["notes"] = notes
        }
        
        if let catID = categoryID {
            input["categoryID"] = catID
        }
        
        // Create the GraphQL mutation manually
        let document = """
        mutation UpdateEntry($input: UpdateEntryInput!) {
          updateEntry(input: $input) {
            id
            date
            totalMinutes
            performer
            activityType
            notes
            propertyID
            categoryID
            createdAt
            updatedAt
          }
        }
        """
        
        do {
            let request = GraphQLRequest<String>(
                document: document,
                variables: ["input": input],
                responseType: String.self,
                decodePath: "updateEntry"
            )
            
            _ = try await Amplify.API.mutate(request: request)
            print("✅ Entry updated successfully")
            
            // Handle images
            var allImageKeys = existingImageKeys
            
            // Upload new images if any
            if !newImages.isEmpty {
                print("📤 Uploading \(newImages.count) new images...")
                let newImageKeys = try await uploadImages(newImages, entryID: entryID)
                allImageKeys.append(contentsOf: newImageKeys)
            }
            
            // Update entry with all image keys
            if !allImageKeys.isEmpty || !existingImageKeys.isEmpty {
                try await updateEntryImages(entryID: entryID, imageKeys: allImageKeys)
            }
            
            // Refresh entries list
            await fetchEntries()
        } catch {
            print("❌ Error updating entry: \(error)")
            print("❌ Error details: \(String(describing: error))")
            throw error
        }
    }
    
    // MARK: - Delete Entry
    
    @MainActor
    func deleteEntry(_ entry: Entry) async throws {
        print("🗑️ Deleting entry \(entry.id)")
        
        // Create custom GraphQL delete mutation that doesn't try to return relationships
        let document = """
        mutation DeleteEntry($input: DeleteEntryInput!) {
          deleteEntry(input: $input) {
            id
            date
            totalMinutes
            performer
            activityType
            notes
            propertyID
            categoryID
          }
        }
        """
        
        let input: [String: Any] = ["id": entry.id]
        
        do {
            let request = GraphQLRequest<String>(
                document: document,
                variables: ["input": input],
                responseType: String.self,
                decodePath: "deleteEntry"
            )
            
            _ = try await Amplify.API.mutate(request: request)
            entries.removeAll { $0.id == entry.id }
            print("✅ Entry deleted successfully")
        } catch {
            print("❌ Error deleting entry: \(error)")
            print("❌ Error details: \(String(describing: error))")
            throw error
        }
    }
    
    // MARK: - Image Upload
    
    @MainActor
    func uploadImages(_ images: [UIImage], entryID: String) async throws -> [String] {
        var uploadedURLs: [String] = []
        
        // Get the Cognito Identity ID (not the User Pool userId)
        // This is required for S3 storage access with IAM policies
        let identityID: String
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            
            // Cast to get access to identity ID
            if let identityProvider = session as? AuthCognitoIdentityProvider {
                identityID = try identityProvider.getIdentityId().get()
            } else {
                throw NSError(domain: "EntriesViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not get Cognito Identity Provider"])
            }
        } catch {
            print("❌ Could not get identity ID: \(error)")
            throw NSError(domain: "EntriesViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not get identity ID for storage: \(error.localizedDescription)"])
        }
        
        print("🔑 Using Identity ID for upload: \(identityID)")
        
        for (index, image) in images.enumerated() {
            // Compress image to JPEG
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                print("⚠️ Failed to convert image \(index) to JPEG")
                continue
            }
            
            // Create unique filename
            let timestamp = Int(Date().timeIntervalSince1970)
            let filename = "\(entryID)_image_\(timestamp)_\(index).jpg"
            let key = "entries/\(identityID)/\(filename)"
            
            print("📤 Uploading image to: \(key)")
            
            do {
                let uploadTask = Amplify.Storage.uploadData(
                    key: key,
                    data: imageData
                )
                
                let result = try await uploadTask.value
                print("✅ Image uploaded successfully: \(result)")
                uploadedURLs.append(result)
            } catch let error as StorageError {
                print("❌ StorageError uploading image \(index):")
                print("   Error type: \(error.errorDescription)")
                print("   Recovery suggestion: \(error.recoverySuggestion)")
                print("   Underlying error: \(error.underlyingError?.localizedDescription ?? "none")")
                throw error
            } catch {
                print("❌ Error uploading image \(index): \(error)")
                print("   Error details: \(String(describing: error))")
                throw error
            }
        }
        
        return uploadedURLs
    }
    
    @MainActor
    func deleteImage(_ imageKey: String) async throws {
        print("🗑️ Deleting image: \(imageKey)")
        
        do {
            try await Amplify.Storage.remove(key: imageKey)
            print("✅ Image deleted successfully")
        } catch {
            print("❌ Error deleting image: \(error)")
            throw error
        }
    }
    
    @MainActor
    func getImageURL(_ imageKey: String) async throws -> URL {
        do {
            let result = try await Amplify.Storage.getURL(key: imageKey)
            return result
        } catch {
            print("❌ Error getting image URL: \(error)")
            throw error
        }
    }
}

