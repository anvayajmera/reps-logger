//
//  EntriesView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify

struct EntriesView: View {
    @State private var viewModel = EntriesViewModel()
    @State private var entryToDelete: Entry?
    @State private var showDeleteConfirmation = false
    @State private var entryToEdit: Entry?
    @State private var dummySelectedTab = 1 // Not used, but needed for AddEntryView
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading entries...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.entries.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Entries Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add your first entry using the + button below")
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
                    // Entries list
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sortedEntries, id: \.id) { entry in
                                EntryRow(entry: entry, viewModel: viewModel)
                                    .onTapGesture {
                                        entryToEdit = entry
                                    }
                                    .contextMenu {
                                        Button {
                                            entryToEdit = entry
                                        } label: {
                                            Label("Edit Entry", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            entryToDelete = entry
                                            showDeleteConfirmation = true
                                        } label: {
                                            Label("Delete Entry", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.fetchEntries()
                    }
                }
            }
            .navigationTitle("Entries")
            .task {
                await viewModel.fetchEntries()
                await viewModel.fetchProperties()
            }
            .sheet(item: $entryToEdit) { entry in
                AddEntryView(viewModel: viewModel, selectedTab: $dummySelectedTab, entryToEdit: entry)
            }
            .alert("Delete Entry", isPresented: $showDeleteConfirmation, presenting: entryToDelete) { entry in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteEntry(entry)
                    }
                }
            } message: { entry in
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
        }
    }
    
    private var sortedEntries: [Entry] {
        viewModel.entries.sorted { entry1, entry2 in
            // Sort by date descending (newest first)
            let date1 = entry1.date.foundationDate ?? Date.distantPast
            let date2 = entry2.date.foundationDate ?? Date.distantPast
            return date1 > date2
        }
    }
    
    private func deleteEntry(_ entry: Entry) async {
        do {
            try await viewModel.deleteEntry(entry)
            print("✅ Entry deleted successfully")
        } catch {
            print("❌ Error deleting entry: \(error)")
        }
    }
}

struct EntryRow: View {
    let entry: Entry
    let viewModel: EntriesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and Duration
            HStack {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            // Activity Description
            Text(entry.activityType)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Property and Performer
            HStack(spacing: 12) {
                if let propertyName = propertyName {
                    HStack(spacing: 4) {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(propertyName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(entry.performer)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: entry.date.foundationDate ?? Date())
    }
    
    private var formattedDuration: String {
        let hours = entry.totalMinutes / 60
        let minutes = entry.totalMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var propertyName: String? {
        // Try to find the property from the viewModel's properties list
        // In a real app, you'd want to fetch this relationship properly
        // For now, we'll just show "Property" as placeholder
        return "Property"
    }
}

#Preview {
    EntriesView()
}

