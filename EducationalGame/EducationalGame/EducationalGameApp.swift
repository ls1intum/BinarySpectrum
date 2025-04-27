//
//  EducationalGameApp.swift
//  EducationalGame
//
//  Created by Lorena K. Vitale on 18.02.25.
//

import SwiftUI
import UIKit

@main
struct EducationalGameApp: App {
    // Use the environment property wrapper for view models
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var navigationState = NavigationState()
    
    // State to control debug features
    @AppStorage("debugMode") private var debugMode = false
    
    init() {
        // Configure app appearance
        configureAppAppearance()
        
        // Print available fonts in debug mode
        if debugMode {
            printAvailableFonts()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(userViewModel)
                .environmentObject(navigationState)
                .preferredColorScheme(.light)
                .tint(.gamePurple)
        }
    }
    
    // MARK: - Private Helper Methods
    
    // Configure overall app appearance
    private func configureAppAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color.gameWhite)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.gamePurple),
            .font: UIFont(name: "Avenir-Heavy", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.gameWhite)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    // Print all available fonts for debugging
    private func printAvailableFonts() {
        for familyName in UIFont.familyNames.sorted() {
            print("Font Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName).sorted() {
                print("    Font: \(fontName)")
            }
        }
    }
}
