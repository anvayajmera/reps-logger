//
//  PropertiesViewModel.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify
internal import AWSPluginsCore

@Observable
class PropertiesViewModel {
    var properties: [Property] = []
    var isLoading = false
    var errorMessage: String?
    
    // Computed properties for filtered lists
    var longTermProperties: [Property] {
        properties.filter { $0.type == "LTR" }
    }
    
    var shortTermProperties: [Property] {
        properties.filter { $0.type == "STR" }
    }
    
    // MARK: - Fetch Properties
    
    @MainActor
    func fetchProperties() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = GraphQLRequest<Property>.list(Property.self)
            let result = try await Amplify.API.query(request: request)
            
            switch result {
            case .success(let propertyList):
                properties = propertyList.elements
                print("✅ Fetched \(properties.count) properties")
            case .failure(let error):
                let errorDescription = String(describing: error)
                errorMessage = "Failed to fetch properties: \(errorDescription)"
                print("❌ Error fetching properties: \(error)")
            }
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to fetch properties: \(errorDescription)"
            print("❌ Error fetching properties: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Add Property
    
    @MainActor
    func addProperty(
        name: String,
        nickname: String?,
        type: String,
        address1: String,
        address2: String?,
        city: String,
        state: String,
        zip: String,
        notes: String?
    ) async throws {
        let newProperty = Property(
            name: name,
            nickname: nickname,
            type: type,
            address1: address1,
            address2: address2,
            city: city,
            state: state,
            zip: zip,
            notes: notes
        )
        
        do {
            let request = GraphQLRequest<Property>.create(newProperty)
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let savedProperty):
                properties.append(savedProperty)
                print("✅ Property added successfully: \(savedProperty.name)")
            case .failure(let error):
                print("❌ Error adding property: \(error)")
                throw error
            }
        } catch {
            print("❌ Error adding property: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete Property
    
    @MainActor
    func deleteProperty(_ property: Property) async throws {
        do {
            let request = GraphQLRequest<Property>.delete(property)
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success:
                properties.removeAll { $0.id == property.id }
                print("✅ Property deleted successfully")
            case .failure(let error):
                print("❌ Error deleting property: \(error)")
                throw error
            }
        } catch {
            print("❌ Error deleting property: \(error)")
            throw error
        }
    }
    
    // MARK: - Update Property
    
    @MainActor
    func updateProperty(_ property: Property) async throws {
        do {
            let request = GraphQLRequest<Property>.update(property)
            let result = try await Amplify.API.mutate(request: request)
            
            switch result {
            case .success(let updatedProperty):
                if let index = properties.firstIndex(where: { $0.id == property.id }) {
                    properties[index] = updatedProperty
                }
                print("✅ Property updated successfully")
            case .failure(let error):
                print("❌ Error updating property: \(error)")
                throw error
            }
        } catch {
            print("❌ Error updating property: \(error)")
            throw error
        }
    }
}

