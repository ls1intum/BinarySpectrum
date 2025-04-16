import SwiftUI

class NavigationState: ObservableObject {
    @Published var path = NavigationPath()
    
    // Convenience methods
    func navigateToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            path = NavigationPath()
        }
    }
    
    // Generic method that requires the destination to be Hashable
    func navigateTo<T: Hashable>(_ destination: T) {
        withAnimation(.easeInOut(duration: 0.3)) {
            path.append(destination)
        }
    }
    
    func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if path.count > 0 {
                path.removeLast()
            }
        }
    }
} 