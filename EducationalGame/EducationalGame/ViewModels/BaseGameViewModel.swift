import Foundation
import SwiftUI

@Observable class BaseGameViewModel {
    var gameType: String
    var currentPhase: GamePhase
    var challengeParams: ChallengeParams?
    var navigationState: NavigationState?
    
    // MARK: - UI State
    
    var showHint = false
    var isCorrect = false
    var hintMessage: LocalizedStringResource = ""
    
    init(gameType: String, initialPhase: GamePhase = .introDialogue) {
        self.gameType = gameType
        self.currentPhase = initialPhase
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetGameState),
            name: NSNotification.Name("ResetGameProgress"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configureWithChallengeParams(_ params: ChallengeParams?) {
        guard let params = params else { return }
        
        challengeParams = params
        currentPhase = params.phase
        
        // Perform any additional setup based on the challenge parameters
        setupForChallenge()
    }
    
    // Override in subclasses to perform challenge-specific setup
    func setupForChallenge() {
        // Default implementation does nothing
    }
    
    func hideHint() {
        showHint = false
        if isCorrect {
            completeGame(score: 100, percentage: 1.0)
        }
    }
    
    func completeGame(score: Int, percentage: Double) {
        // Record completion using the shared userViewModel
        sharedUserViewModel.completeMiniGame("\(gameType) - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
        
        // Play appropriate sound based on the phase
        switch currentPhase {
        case .noviceChallenge:
            SoundService.shared.playSound(.levelUp1)
        case .apprenticeChallenge:
            SoundService.shared.playSound(.levelUp2)
        case .adeptChallenge:
            SoundService.shared.playSound(.levelUp3)
        case .expertChallenge:
            SoundService.shared.playSound(.levelUp4)
        case .review:
            SoundService.shared.playSound(.badge)
        default:
            break
        }
        
        // If we're in challenge mode, always return to challenges view
        if challengeParams != nil {
            // Notify that the challenge is complete
            if let params = challengeParams {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ChallengeCompleted"),
                    object: nil,
                    userInfo: ["challengeId": params.challengeId]
                )
            }
            
            // Navigate back to challenges view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.navigationState?.returnToChallengesView()
                }
            }
        } else {
            // Normal flow - advance to next phase
            currentPhase.next(for: gameType)
        }
    }
    
    func nextPhase() {
        // Don't advance phase if we're in challenge mode
        if challengeParams == nil {
            currentPhase.next(for: gameType)
        }
    }
    
    @objc func resetGameState() {
        resetGame()
    }
    
    // Override in subclasses to perform game-specific reset
    func resetGame() {
        currentPhase = .introDialogue
        showHint = false
        isCorrect = false
        hintMessage = ""
    }
}
