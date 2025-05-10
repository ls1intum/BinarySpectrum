import Foundation
import SwiftUI

class NavigationState: ObservableObject {
    @Published var currentScreen: Screen = .home
    @Published var path = NavigationPath()
    @Published var challengeParams: ChallengeParams?
    
    var canGoBack: Bool {
        !path.isEmpty
    }
    
    func navigate(to screen: Screen) {
        path.append(screen)
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func returnToChallengesView() {
        // Reset path to go back to the challenges view
        while !path.isEmpty {
            path.removeLast()
        }
        // Navigate to challenges
        navigate(to: .challenges)
        // Clear challenge params
        challengeParams = nil
    }
    
    func navigateToChallenge(gameId: Int, params: ChallengeParams) {
        // Store challenge parameters
        challengeParams = params
        
        // Navigate to the appropriate game
        switch gameId {
        case 0:
            navigate(to: .binaryGame)
        case 1:
            navigate(to: .pixelGame)
        case 2:
            navigate(to: .colorGame)
        default:
            break
        }
    }
}

enum Screen: Hashable {
    case home
    case binaryGame
    case pixelGame
    case colorGame
    case challenges
    case settings
    case achievements
    case about
}
