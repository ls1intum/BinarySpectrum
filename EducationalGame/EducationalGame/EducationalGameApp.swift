//
//  EducationalGameApp.swift
//  EducationalGame
//
//  Created by Lorena K. Vitale on 18.02.25.
//

import SwiftUI
import UIKit

// Create a shared instance of UserViewModel to access globally
let sharedUserViewModel = UserViewModel()

// App delegate to enforce orientation
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Return landscape orientations only
        return .landscape
    }
}

@main
struct EducationalGameApp: App {
    // Use the shared instance
    @StateObject private var userViewModel = sharedUserViewModel
    
    // Register app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
        }
    }
}
