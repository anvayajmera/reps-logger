//
//  PropertiesView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify

struct PropertiesView: View {
    @State private var showingAddProperty = false
    @State private var viewModel = PropertiesViewModel()
    @State private var propertyToDelete: Property?
    @State private var showDeleteConfirmation = false
    @State private var propertyToEdit: Property?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.properties.isEmpty {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading properties...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.properties.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Properties Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your first property to get started")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .padding()
                } else {
                    // Properties list
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Long-term rentals section
                            if !viewModel.longTermProperties.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "house.fill")
                                            .foregroundColor(.blue)
                                        Text("LONG-TERM RENTALS")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.longTermProperties, id: \.id) { property in
                                            PropertyRow(property: property)
                                                .onTapGesture {
                                                    propertyToEdit = property
                                                }
                                                .contextMenu {
                                                    Button {
                                                        propertyToEdit = property
                                                    } label: {
                                                        Label("Edit Property", systemImage: "pencil")
                                                    }
                                                    
                                                    Button(role: .destructive) {
                                                        propertyToDelete = property
                                                        showDeleteConfirmation = true
                                                    } label: {
                                                        Label("Delete Property", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            
                            // Short-term rentals section
                            if !viewModel.shortTermProperties.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "house.fill")
                                            .foregroundColor(.blue)
                                        Text("SHORT-TERM RENTALS")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.shortTermProperties, id: \.id) { property in
                                            PropertyRow(property: property)
                                                .onTapGesture {
                                                    propertyToEdit = property
                                                }
                                                .contextMenu {
                                                    Button {
                                                        propertyToEdit = property
                                                    } label: {
                                                        Label("Edit Property", systemImage: "pencil")
                                                    }
                                                    
                                                    Button(role: .destructive) {
                                                        propertyToDelete = property
                                                        showDeleteConfirmation = true
                                                    } label: {
                                                        Label("Delete Property", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.fetchProperties()
                    }
                }
            }
            .navigationTitle("Properties")
            .task {
                await viewModel.fetchProperties()
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    showingAddProperty = true
                }) {
                    Label("Add a New Property", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .sheet(isPresented: $showingAddProperty) {
                AddPropertyView(viewModel: viewModel)
            }
            .sheet(item: $propertyToEdit) { property in
                AddPropertyView(viewModel: viewModel, propertyToEdit: property)
            }
            .alert("Delete Property", isPresented: $showDeleteConfirmation, presenting: propertyToDelete) { property in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteProperty(property)
                    }
                }
            } message: { property in
                Text("Are you sure you want to delete '\(property.nickname ?? property.name)'? This action cannot be undone.")
            }
        }
    }
    
    private func deleteProperty(_ property: Property) async {
        do {
            try await viewModel.deleteProperty(property)
            print("✅ Property deleted successfully")
        } catch {
            print("❌ Error deleting property: \(error)")
            // You could add an error alert here if needed
        }
    }
}

struct PropertyRow: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property.nickname ?? property.name)
                .font(.body)
                .foregroundColor(.primary)
                .italic(property.nickname != nil)
            
            Text(fullAddress)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }
    
    private var fullAddress: String {
        var address = property.address1
        if let address2 = property.address2, !address2.isEmpty {
            address += ", \(address2)"
        }
        address += ", \(property.city), \(property.state) \(property.zip), USA"
        return address
    }
}

#Preview {
    PropertiesView()
}
