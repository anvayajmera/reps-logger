//
//  ManageEntryCategoriesView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/16/25.
//

import SwiftUI
import Amplify

struct ManageEntryCategoriesView: View {
    @State private var viewModel = EntriesViewModel()
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDisclaimer = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Disclaimer Banner
                if showDisclaimer {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Note:")
                                    .font(.headline)
                                    .italic()
                                
                                Text("The following categories are recommendations only. You may rename or delete them, or add new.")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("REPSLog is NOT a lawyer or CPA, and this is not legal or financial advice. Please consult a qualified professional for guidance regarding IRS rules and regulations.")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    showDisclaimer = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                
                // Categories List
                ScrollView {
                    VStack(spacing: 0) {
                        // Section Header
                        HStack {
                            Text("DEFAULT CATEGORIES")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        // Categories List
                        VStack(spacing: 0) {
                            ForEach(viewModel.categories) { category in
                                CategoryRow(category: category, viewModel: viewModel)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Add Category Inline Form
                        if showAddCategory {
                            VStack(spacing: 16) {
                                TextField("Category Name", text: $newCategoryName)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    Button("Cancel") {
                                        withAnimation {
                                            showAddCategory = false
                                            newCategoryName = ""
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                    
                                    Button("Add") {
                                        Task {
                                            await addCategory()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                                    .opacity(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 80)
                }
                
                // Add Button at Bottom
                if !showAddCategory {
                    Button(action: {
                        withAnimation {
                            showAddCategory = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add a New Category")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 36)
                    .padding(.bottom, 20)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }
        .navigationTitle("Manage Entry Categories")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCategories()
        }
        .alert("Category Status", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadCategories() async {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        #endif
        
        await viewModel.fetchCategories()
    }
    
    private func addCategory() async {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter a category name"
            showAlert = true
            return
        }
        
        // Check for duplicates
        if viewModel.categories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            alertMessage = "A category with this name already exists"
            showAlert = true
            return
        }
        
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
            
            let input: [String: Any] = ["name": trimmedName]
            
            let request = GraphQLRequest<String>(
                document: document,
                variables: ["input": input],
                responseType: String.self,
                decodePath: "createCategory"
            )
            
            _ = try await Amplify.API.mutate(request: request)
            print("✅ Created category: \(trimmedName)")
            
            // Reload categories
            await viewModel.fetchCategories()
            
            // Reset form
            withAnimation {
                showAddCategory = false
                newCategoryName = ""
            }
            
        } catch {
            alertMessage = "Failed to add category: \(error.localizedDescription)"
            showAlert = true
            print("❌ Error adding category: \(error)")
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    let viewModel: EntriesViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "house.fill")
                .foregroundColor(.blue)
                .font(.system(size: 20))
            
            Text(category.name)
                .font(.system(size: 17))
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Category", systemImage: "trash")
            }
        }
        .alert("Delete Category", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteCategory()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(category.name)'? This action cannot be undone.")
        }
        
        if viewModel.categories.last?.id != category.id {
            Divider()
                .padding(.leading, 52)
        }
    }
    
    private func deleteCategory() async {
        do {
            let document = """
            mutation DeleteCategory($input: DeleteCategoryInput!) {
              deleteCategory(input: $input) {
                id
                name
              }
            }
            """
            
            let input: [String: Any] = ["id": category.id]
            
            let request = GraphQLRequest<String>(
                document: document,
                variables: ["input": input],
                responseType: String.self,
                decodePath: "deleteCategory"
            )
            
            _ = try await Amplify.API.mutate(request: request)
            print("✅ Category deleted successfully")
            
            // Reload categories
            await viewModel.fetchCategories()
        } catch {
            print("❌ Error deleting category: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ManageEntryCategoriesView()
    }
}

