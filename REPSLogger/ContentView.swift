//
//  ContentView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify
import Authenticator

struct ContentView: View {
    @State private var entriesViewModel = EntriesViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Authenticator { state in
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                EntriesView()
                    .tabItem {
                        Label("Entries", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                AddEntryView(viewModel: entriesViewModel, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(2)
                
                PropertiesView()
                    .tabItem {
                        Label("Properties", systemImage: "building.2.fill")
                    }
                    .tag(3)
                
                SettingsView(signedInState: state)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
        }
    }
}

#Preview {
    ContentView()
}


