//
//  AddPropertyView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify

struct AddPropertyView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: PropertiesViewModel
    let propertyToEdit: Property?
    
    // Form fields
    @State private var address1: String
    @State private var address2: String
    @State private var city: String
    @State private var state: String
    @State private var zip: String
    @State private var nickname: String
    @State private var propertyType: String
    @State private var notes: String
    
    // UI State
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDeleteConfirmation = false
    
    // Computed property for mode
    private var isEditMode: Bool {
        propertyToEdit != nil
    }
    
    // US States for picker
    private let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
        "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
        "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
        "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
        "New Hampshire", "New Jersey", "New Mexico", "New York",
        "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
        "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
        "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
        "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    // Initialize with empty values or existing property
    init(viewModel: PropertiesViewModel, propertyToEdit: Property? = nil) {
        self.viewModel = viewModel
        self.propertyToEdit = propertyToEdit
        
        // Initialize state variables with property values if editing
        if let property = propertyToEdit {
            _address1 = State(initialValue: property.address1)
            _address2 = State(initialValue: property.address2 ?? "")
            _city = State(initialValue: property.city)
            _state = State(initialValue: property.state)
            _zip = State(initialValue: property.zip)
            _nickname = State(initialValue: property.nickname ?? "")
            _propertyType = State(initialValue: property.type)
            _notes = State(initialValue: property.notes ?? "")
        } else {
            _address1 = State(initialValue: "")
            _address2 = State(initialValue: "")
            _city = State(initialValue: "")
            _state = State(initialValue: "New York")
            _zip = State(initialValue: "")
            _nickname = State(initialValue: "")
            _propertyType = State(initialValue: "LTR")
            _notes = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Address Line 1
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address Line 1*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextField("Address Line 1", text: $address1)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Address Line 2
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address Line 2 (Optional)")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextField("Address 2", text: $address2)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // City
                    VStack(alignment: .leading, spacing: 8) {
                        Text("City*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextField("City", text: $city)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // State
                    VStack(alignment: .leading, spacing: 8) {
                        Text("State*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Picker("State", selection: $state) {
                            ForEach(usStates, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Zip Code
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Zip Code*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextField("Zip Code", text: $zip)
                            .textFieldStyle(.plain)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Nickname
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nickname*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextField("Property Nickname", text: $nickname)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Property Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Property Type*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                propertyType = "LTR"
                            }) {
                                Text("Long Term Rental")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(propertyType == "LTR" ? .white : .primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(propertyType == "LTR" ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                propertyType = "STR"
                            }) {
                                Text("Short Term Rental")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(propertyType == "STR" ? .white : .primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(propertyType == "STR" ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(isEditMode ? "Edit Property" : "Add a New Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                if isEditMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    Task {
                        await addProperty()
                    }
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isSaving ? (isEditMode ? "Saving..." : "Adding...") : (isEditMode ? "Save Property" : "Add Property"))
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid && !isSaving ? Color.blue : Color.gray)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .disabled(!isFormValid || isSaving)
                .padding(.bottom)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Delete Property", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteProperty()
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(nickname.isEmpty ? address1 : nickname)'? This action cannot be undone.")
            }
        }
    }
    
    private var isFormValid: Bool {
        !address1.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty && !nickname.isEmpty
    }
    
    private func addProperty() async {
        guard isFormValid else { return }
        
        isSaving = true
        
        do {
            // Generate the name from the full address
            let name = "\(address1), \(city), \(state) \(zip)"
            
            if isEditMode, let existingProperty = propertyToEdit {
                // Update existing property
                let updatedProperty = Property(
                    id: existingProperty.id,
                    name: name,
                    nickname: nickname.isEmpty ? nil : nickname,
                    type: propertyType,
                    address1: address1,
                    address2: address2.isEmpty ? nil : address2,
                    city: city,
                    state: state,
                    zip: zip,
                    acquiredDate: existingProperty.acquiredDate,
                    isActive: existingProperty.isActive,
                    notes: notes.isEmpty ? nil : notes
                )
                
                try await viewModel.updateProperty(updatedProperty)
                print("✅ Property updated successfully!")
            } else {
                // Create new property
                try await viewModel.addProperty(
                    name: name,
                    nickname: nickname.isEmpty ? nil : nickname,
                    type: propertyType,
                    address1: address1,
                    address2: address2.isEmpty ? nil : address2,
                    city: city,
                    state: state,
                    zip: zip,
                    notes: notes.isEmpty ? nil : notes
                )
                print("✅ Property added successfully!")
            }
            
            dismiss()
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to \(isEditMode ? "update" : "add") property: \(errorDescription)"
            showError = true
            print("❌ Error \(isEditMode ? "updating" : "adding") property: \(error)")
        }
        
        isSaving = false
    }
    
    private func deleteProperty() async {
        guard let property = propertyToEdit else { return }
        
        do {
            try await viewModel.deleteProperty(property)
            print("✅ Property deleted successfully")
            dismiss()
        } catch {
            let errorDescription = String(describing: error)
            errorMessage = "Failed to delete property: \(errorDescription)"
            showError = true
            print("❌ Error deleting property: \(error)")
        }
    }
}

#Preview {
    AddPropertyView(viewModel: PropertiesViewModel())
}

