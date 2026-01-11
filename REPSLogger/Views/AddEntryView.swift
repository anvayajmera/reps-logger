//
//  AddEntryView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import UIKit
import Amplify

struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: EntriesViewModel
    let entryToEdit: Entry?
    @Binding var selectedTab: Int
    
    // Form fields
    @State private var servicesPerformed: String
    @State private var selectedDate: Date
    @State private var hours: String
    @State private var minutes: String
    @State private var selectedPropertyID: String?
    @State private var performer: String
    @State private var selectedCategoryID: String?
    
    // UI State
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    @State private var isLoadingData = true
    @State private var isKeyboardVisible = false
    @State private var showDeleteConfirmation = false
    
    // Image Upload State
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var cameraImage: UIImage?
    @State private var showImageLimitAlert = false
    private let maxImages = 2
    
    let performerOptions = ["Myself", "Contractor", "Property Manager", "Other"]
    
    // Computed property for mode
    private var isEditMode: Bool {
        entryToEdit != nil
    }
    
    // Initialize with empty values or existing entry
    init(viewModel: EntriesViewModel, selectedTab: Binding<Int>, entryToEdit: Entry? = nil) {
        self.viewModel = viewModel
        self.entryToEdit = entryToEdit
        self._selectedTab = selectedTab
        
        // Initialize state variables with entry values if editing
        if let entry = entryToEdit {
            _servicesPerformed = State(initialValue: entry.activityType)
            _selectedDate = State(initialValue: entry.date.foundationDate)
            
            let totalHours = entry.totalMinutes / 60
            let totalMinutes = entry.totalMinutes % 60
            _hours = State(initialValue: String(totalHours))
            _minutes = State(initialValue: String(totalMinutes))
            
            _performer = State(initialValue: entry.performer)
            _selectedPropertyID = State(initialValue: nil) // Will be loaded from relationship
            _selectedCategoryID = State(initialValue: nil) // Will be loaded from relationship
        } else {
            _servicesPerformed = State(initialValue: "")
            _selectedDate = State(initialValue: Date())
            _hours = State(initialValue: "")
            _minutes = State(initialValue: "")
            _selectedPropertyID = State(initialValue: nil)
            _performer = State(initialValue: "Myself")
            _selectedCategoryID = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationStack {
            if isLoadingData {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Add a New Entry")
                .navigationBarTitleDisplayMode(.inline)
            } else if viewModel.properties.isEmpty {
                // Empty state when no properties exist
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Properties Available")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Please add a property before creating an entry")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Add a New Entry")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Services Performed Section
                        VStack(alignment: .leading, spacing: 8) {
                        Text("Services Performed?*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        ZStack(alignment: .topLeading) {
                            if servicesPerformed.isEmpty {
                                Text("Example: Yesterday, I went to Home Depot to shop for construction materials for renovating the kitchen of my Barrington Ave property. It lasted 1 hour and 40 minutes.")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .font(.body)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $servicesPerformed)
                                .frame(minHeight: 120)
                                .padding(4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Date, Hours, Minutes Section
                    HStack(spacing: 12) {
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date*")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Hours
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hours*")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            TextField("0", text: $hours)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Minutes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Minutes*")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            TextField("0", text: $minutes)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Property Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Property*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Menu {
                            ForEach(viewModel.properties) { property in
                                Button {
                                    selectedPropertyID = property.id
                                } label: {
                                    HStack {
                                        Text(property.nickname ?? property.name)
                                        if selectedPropertyID == property.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPropertyName)
                                    .foregroundColor(selectedPropertyID == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Performer Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who Performed the Activity?*")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Menu {
                            ForEach(performerOptions, id: \.self) { option in
                                Button {
                                    performer = option
                                } label: {
                                    HStack {
                                        Text(option)
                                        if performer == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(performer)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category (Optional)")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Menu {
                            Button {
                                selectedCategoryID = nil
                            } label: {
                                HStack {
                                    Text("None")
                                    if selectedCategoryID == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            ForEach(viewModel.categories) { category in
                                Button {
                                    selectedCategoryID = category.id
                                } label: {
                                    HStack {
                                        Text(category.name)
                                        if selectedCategoryID == category.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategoryName)
                                    .foregroundColor(selectedCategoryID == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Add Supporting Documents Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Supporting Documents")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("Upload images, receipts or documents to support your activity. (Max \(maxImages) images)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Display selected images
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            Button(action: {
                                                selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.opacity(0.8))
                                                    .clipShape(Circle())
                                            }
                                            .offset(x: 8, y: -8)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Upload buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                if selectedImages.count < maxImages {
                                    showImagePicker = true
                                } else {
                                    showImageLimitAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Photo Library")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                if selectedImages.count < maxImages {
                                    showCamera = true
                                } else {
                                    showImageLimitAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Take Photo")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle(isEditMode ? "Edit Entry" : "Add a New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isEditMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                if isKeyboardVisible {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                } else if isEditMode {
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
            .onAppear {
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
            .onTapGesture {
                hideKeyboard()
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await submitEntry()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    } else {
                        Text(isEditMode ? "Save Entry" : "Add Entry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .disabled(isSubmitting || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            }
            }
        }
            .alert("Entry Status", isPresented: $showAlert) {
                Button("OK") {
                    if !alertMessage.contains("Error") {
                        if isEditMode {
                            dismiss()
                        } else {
                            // Clear the form after successful submission
                            resetForm()
                        }
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .alert("Delete Entry", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteEntry()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
            .alert("Image Limit Reached", isPresented: $showImageLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can only upload a maximum of \(maxImages) images per entry. This limit helps keep your log organized and ensures optimal performance.")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    selectedImages: $selectedImages,
                    maxSelection: maxImages - selectedImages.count
                )
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(selectedImage: $cameraImage)
            }
            .onChange(of: cameraImage) { oldValue, newValue in
                if let newImage = newValue {
                    selectedImages.append(newImage)
                    cameraImage = nil
                }
            }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Computed Properties
    
    private var selectedPropertyName: String {
        if let propertyID = selectedPropertyID,
           let property = viewModel.properties.first(where: { $0.id == propertyID }) {
            return property.nickname ?? property.name
        }
        return "Select a Property"
    }
    
    private var selectedCategoryName: String {
        if let categoryID = selectedCategoryID,
           let category = viewModel.categories.first(where: { $0.id == categoryID }) {
            return category.name
        }
        return "Select a Category"
    }
    
    private var isFormValid: Bool {
        !servicesPerformed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedPropertyID != nil &&
        !hours.isEmpty &&
        !minutes.isEmpty &&
        (Int(hours) ?? 0) >= 0 &&
        (Int(minutes) ?? 0) >= 0
    }
    
    // MARK: - Methods
    
    @MainActor
    private func loadData() async {
        // Skip loading in preview mode to prevent crashes
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            isLoadingData = false
            return
        }
        #endif
        
        print("📱 AddEntryView: Starting loadData()")
        isLoadingData = true
        
        print("📱 AddEntryView: Fetching properties...")
        await viewModel.fetchProperties()
        print("📱 AddEntryView: Properties fetch complete. Count: \(viewModel.properties.count)")
        
        print("📱 AddEntryView: Fetching categories...")
        await viewModel.fetchCategories()
        print("📱 AddEntryView: Categories fetch complete. Count: \(viewModel.categories.count)")
        
        // If editing, try to load the property and category IDs from the entry
        if let entry = entryToEdit {
            // Try to get property ID from the entry
            Task {
                do {
                    if let property = try await entry.property {
                        selectedPropertyID = property.id
                        print("📱 AddEntryView: Set property to \(property.name)")
                    }
                    
                    if let category = try await entry.category {
                        selectedCategoryID = category.id
                        print("📱 AddEntryView: Set category to \(category.name)")
                    }
                } catch {
                    print("⚠️ AddEntryView: Error loading relationships: \(error)")
                }
            }
        }
        
        isLoadingData = false
        print("📱 AddEntryView: loadData() complete")
    }
    
    @MainActor
    private func submitEntry() async {
        guard isFormValid else { return }
        
        // Skip submission in preview mode
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            alertMessage = "Preview mode - entry not saved"
            showAlert = true
            return
        }
        #endif
        
        isSubmitting = true
        
        do {
            let hoursInt = Int(hours) ?? 0
            let minutesInt = Int(minutes) ?? 0
            
            if isEditMode, let existingEntry = entryToEdit {
                // Update existing entry
                // TODO: Get existing image keys from entry
                let existingImageKeys = existingEntry.images ?? []
                
                try await viewModel.updateEntry(
                    entryID: existingEntry.id,
                    propertyID: selectedPropertyID!,
                    categoryID: selectedCategoryID,
                    date: selectedDate,
                    hours: hoursInt,
                    minutes: minutesInt,
                    performer: performer,
                    activityType: servicesPerformed,
                    notes: nil,
                    newImages: selectedImages,
                    existingImageKeys: existingImageKeys as! [String]
                )
                
                alertMessage = "Entry updated successfully!"
                showAlert = true
            } else {
                // Create new entry
                _ = try await viewModel.addEntry(
                    propertyID: selectedPropertyID!,
                    categoryID: selectedCategoryID,
                    date: selectedDate,
                    hours: hoursInt,
                    minutes: minutesInt,
                    performer: performer,
                    activityType: servicesPerformed,
                    notes: nil,
                    images: selectedImages
                )
                
                alertMessage = "Entry added successfully!"
                showAlert = true
                
                // Navigate to Entries tab after successful add
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedTab = 1 // Entries tab is at index 1
                }
            }
        } catch {
            alertMessage = "Error \(isEditMode ? "updating" : "adding") entry: \(error.localizedDescription)"
            showAlert = true
        }
        
        isSubmitting = false
    }
    
    private func resetForm() {
        servicesPerformed = ""
        hours = ""
        minutes = ""
        selectedPropertyID = nil
        selectedCategoryID = nil
        selectedDate = Date()
        performer = "Myself"
        selectedImages = []
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = true
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            isKeyboardVisible = false
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func deleteEntry() async {
        guard let entry = entryToEdit else { return }
        
        do {
            try await viewModel.deleteEntry(entry)
            print("✅ Entry deleted successfully")
            dismiss()
        } catch {
            alertMessage = "Failed to delete entry: \(error.localizedDescription)"
            showAlert = true
            print("❌ Error deleting entry: \(error)")
        }
    }
}

#Preview {
    AddEntryView(viewModel: EntriesViewModel(), selectedTab: .constant(2))
}

