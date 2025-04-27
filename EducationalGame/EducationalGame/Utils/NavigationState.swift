import SwiftUI

/// Manages navigation state for the entire app
final class NavigationState: ObservableObject {
    // The navigation path representing the current navigation stack
    @Published var path = NavigationPath()
    
    // The current screen being shown
    @Published var currentScreen: String = "home"
    
    // Navigation history for enabling "back" functionality
    private var navigationHistory: [String] = []
    
    // Reset navigation to the root
    func navigateToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            path = NavigationPath()
            currentScreen = "home"
            navigationHistory = []
        }
    }
    
    // Navigate to a destination with animation
    func navigateTo<T: Hashable>(_ destination: T) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let stringDest = destination as? String {
                navigationHistory.append(currentScreen)
                currentScreen = stringDest
            }
            path.append(destination)
        }
    }
    
    // Go back one step in the navigation stack
    func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if path.count > 0 {
                path.removeLast()
                if !navigationHistory.isEmpty {
                    currentScreen = navigationHistory.removeLast()
                }
            }
        }
    }
    
    // Check if we can go back from the current screen
    var canGoBack: Bool {
        path.count > 0
    }
}
