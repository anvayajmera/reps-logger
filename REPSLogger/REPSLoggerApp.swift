//
//  REPSLoggerApp.swift
//  REPSLogger
//
//  Created by Aagam Bakliwal on 11/15/25.
//

import SwiftUI
import Amplify
import Authenticator
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

@main
struct REPSLoggerApp: App {
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            
            // Register models BEFORE configuring API plugin
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            
            // Add S3 Storage plugin
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            // Configure Amplify - REQUIRES codegen to be run first
            // Run: npx ampx codegen
            try Amplify.configure(with: .amplifyOutputs)
            
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Unable to configure Amplify: \(error)")
            print("")
            print("🔴 ERROR: Codegen has not been run!")
            print("")
            print("💡 SOLUTION: Run the following command in your project root:")
            print("   npx ampx codegen")
            print("")
            print("   Then rebuild your Xcode project.")
            fatalError("Amplify configuration failed. Run 'npx ampx codegen' first.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 