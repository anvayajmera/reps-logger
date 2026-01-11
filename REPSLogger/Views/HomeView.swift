//
//  HomeView.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to REPS Logger!")
                    .font(.title)
                    .padding()
                
                Text("You are successfully authenticated!")
                    .foregroundColor(.green)
                    .padding()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}

