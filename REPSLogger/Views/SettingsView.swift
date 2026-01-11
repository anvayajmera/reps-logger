//
//  SettingsView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Authenticator
import Amplify

struct SettingsView: View {
    let signedInState: SignedInState
    @State private var userEmail: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Email Section
                        HStack {
                            Text(userEmail)
                                .font(.system(size: 17))
                            
                            Spacer()
                            
                            Text("Premium")
                                .font(.system(size: 15, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Settings List
                        VStack(spacing: 0) {
                            // Manage Entry Categories
                            NavigationLink(destination: ManageEntryCategoriesView()) {
                                SettingsRow(
                                    icon: "square.grid.2x2",
                                    title: "Manage Entry Categories"
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            // Sign Out
                            Button(action: {
                                Task {
                                    await signedInState.signOut()
                                }
                            }) {
                                SettingsRow(
                                    icon: "arrow.right.square",
                                    title: "Sign Out",
                                    isDestructive: false
                                )
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await loadUserEmail()
            }
        }
    }
    
    private func loadUserEmail() async {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            userEmail = user.username
        } catch {
            print("Error fetching user: \(error)")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isDestructive ? .red : .primary)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(isDestructive ? .red : .primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    // Note: Preview requires AuthenticatorState, which is typically provided by Authenticator
    Text("Settings Preview")
}

