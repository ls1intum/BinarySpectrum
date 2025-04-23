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
    
    // Global navigation state
    @StateObject private var navigationState = NavigationState()
    
    // State to control showing splash screen
    @State private var showSplashScreen = true
    
    // Register app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Debug: Print all available fonts
        for familyName in UIFont.familyNames.sorted() {
            print("Font Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName).sorted() {
                print("    Font: \(fontName)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(userViewModel)
                    .environmentObject(navigationState)
                    .preferredColorScheme(.light)
                    .opacity(showSplashScreen ? 0 : 1)
                
                if showSplashScreen {
                    SplashScreenView(onFinished: {
                        showSplashScreen = false
                    })
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplashScreen)
        }
    }
}
