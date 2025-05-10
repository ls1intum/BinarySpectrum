import Foundation
import SwiftUI

class ChallengesViewModel: ObservableObject {
    @Published var selectedMiniGame: Int = 0
    
    func getChallengesForSelectedGame() -> [Challenge] {
        return GameConstants.challenges.filter { $0.miniGameId == selectedMiniGame }
    }
    
    func getSelectedMiniGameColor() -> Color {
        guard selectedMiniGame < GameConstants.miniGames.count else { return .gray }
        return GameConstants.miniGames[selectedMiniGame].color
    }
    
    func startChallenge(challenge: Challenge, navigationState: NavigationState) {
        // Create challenge parameters
        let params = ChallengeParams(
            miniGameId: selectedMiniGame,
            challengeId: challenge.id,
            phase: challenge.phase,
            returnToChallenges: true
        )
        
        // Store challenge parameters in navigation state
        navigationState.challengeParams = params
        
        // Navigate to the appropriate mini-game using the path
        navigationState.path.append(params)
    }
}

// Challenge parameters to pass to games
struct ChallengeParams {
    let miniGameId: Int
    let challengeId: Int
    let phase: GamePhase
    let returnToChallenges: Bool
}