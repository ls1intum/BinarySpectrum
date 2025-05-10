import Foundation
import SwiftUI

// Service for providing contextual information throughout the app
class InfoButtonService {
    // Shared instance for easy access
    static let shared = InfoButtonService()
    
    // Store predefined tip content for different views and phases
    private let gameInfoTips: [String: [GamePhase: LocalizedStringResource]] = [
        String(localized: GameConstants.miniGames[0].name): [
            .introDialogue: "Welcome to \(GameConstants.miniGames[0].name), a mini game about binary numbers. Touch the arrows on the bottom and see what Alex has to say.",
            .questions: "Test your understanding of binary concepts. Select the answer you think is correct, no problem if is not correct.",
            .exploration: "Explore converting between binary and decimal. In binary, each position represents a power of 2: 1, 2, 4, 8, 16, etc.",
            .tutorialDialogue: "Let Alex explain to you how to solve the next challenges.",
            .noviceChallenge: "Practice converting decimal numbers to binary. Remember: each position represents a power of 2: 1, 2, 4, 8.",
            .apprenticeChallenge: "Practice converting decimal numbers to binary. Remember: each position represents a power of 2: 1, 2, 4, 8, 16.",
            .adeptChallenge: "Now try to do the opposite and figure out which number this binary code represents. Remember: each position represents a power of 2: 1, 2, 4, 8, 16.",
            .lastDialogue: "Let Alex explain to you how to solve the final challenge.",
            .expertChallenge: "Switch the digits to represent your birthdate and get your binary armband. Remember: each position represents a power of 2: 1, 2, 4, 8, 16.",
            .review: "Review what you've learned about binary numbers and their role in computing. Check the boxes that correspond to what you've learned.",
            .reward: "Congratulations, you finished the mini game and received a badge for your good work!."
        ],
        String(localized: GameConstants.miniGames[1].name): [
            .introDialogue: "Welcome to \(GameConstants.miniGames[1].name), a mini game about pixel art. Touch the arrows on the bottom and see what Pixie has to say.",
            .questions: "Test your understanding of digital pictures. Select the answer you think is correct, no problem if is not correct.",
            .exploration: "Try creating a simple image using an 8×8 grid. Think of each cell as a pixel that can be either on or off. Name your creation at the end.",
            .noviceChallenge: "Transform code into art by change the color of the pixels to black where there is a one.",
            .apprenticeChallenge: "Now try to do the opposite by coding the pixel art in binary. Remember: white is 0 and black is 1.",
            .tutorialDialogue: "Let Pixie explain to you how to solve the next challenges.",
            .adeptChallenge: "Transform code into art by change the color of the pixels to black where there is a one.",
            .lastDialogue: "Let Pixie explain to you how to solve the final challenge.",
            .expertChallenge: "Challenge yourself to create images that can be efficiently compressed while still looking good.",
            .review: "Review what you've learned about how images are stored in pixels. Check the boxes that correspond to what you've learned.",
            .reward: "Congratulations, you finished the mini game and received a badge for your good work!."
        ],
        String(localized: GameConstants.miniGames[2].name): [
            .introDialogue: "Welcome to \(GameConstants.miniGames[2].name), a mini game about digital colors. Touch the arrows on the bottom and see what Iris has to say.",
            .questions: "Test your understanding of how the RGB color model works. Select the answer you think is correct, no problem if is not correct.",
            .exploration: "Experiment with RGB (red, green, blue) values to create different colors.",
            .tutorialDialogue: "Let Iris explain to you how to solve the first challenge.",
            .noviceChallenge: "Adjust the RGB values with the pickers to match the given color.",
            .lastDialogue: "Let Pixie explain to you how to solve the next challenges.",
            .apprenticeChallenge: "Adjust the RGB and alpha values with the pickers to match the given color and its opacity.",
            .adeptChallenge: "Remember: the two first digits represent the red amount, then the green, then the blue. The values go from 00 (weak) to FF (strong).",
            .expertChallenge: "Rotate the opacity volume button to decypher the hidden message and write it on the text field.",
            .review: "Review what you've learned about digital colors, hex codes, and opacity. Check the boxes that correspond to what you've learned.",
            .reward: "Congratulations, you finished the mini game and received a badge for your good work!."
        ]
    ]
    
    // Specific tips for views without phases
    private let nonPhaseViewTips: [String: LocalizedStringResource] = [
        "Main Menu": "Welcome to \(GameConstants.gameTitle)! Choose a mini-game to start learning about computer science concepts in a fun way.",
        "Achievements": "Here you can see your progress and achievements. Complete mini-games and challenges to unlock more achievements!",
        "Challenges": "Here you can select a specific mini-game challenge to play directly."
    ]
    
    // Get title for info popup based on view and phase (or just view for phaseless views)
    func getTitleForInfo(view: String, phase: GamePhase? = nil) -> String {
        // Handle views without phases explicitly
        if view == GameConstants.gameTitle || view == "Main Menu" {
            return "Main Menu"
        }
        
        if view == "Achievements" {
            return "Your Achievements"
        }

        if view == "Challenges" {
            return "Challenges"
        }

        let nameToGame = Dictionary(
            uniqueKeysWithValues: GameConstants.miniGames.map { (String(localized: $0.name), $0) }
        )

        if let game = nameToGame[view], let phase = phase {
            return "\(String(localized: game.name)) - \(phase.rawValue)"
        }

        return GameConstants.gameTitle
    }
    
    // Get a tip for current view and phase
    func getTip(for view: String, phase: GamePhase? = nil) -> LocalizedStringResource? {
        if view == GameConstants.gameTitle || view == "Main Menu" {
            return nonPhaseViewTips["Main Menu"]
        }
        
        if view == "Achievements" {
            return nonPhaseViewTips["Achievements"]
        }

        if view == "Challenges" {
            return nonPhaseViewTips["Challenges"]
        }
        
        // Use the same name-to-game mapping as getTitleForInfo
        let nameToGame = Dictionary(
            uniqueKeysWithValues: GameConstants.miniGames.map { (String(localized: $0.name), $0) }
        )
        
        // If this is a game view
        if let game = nameToGame[view] {
            // Get the localized game name
            let gameName = String(localized: game.name)
            
            // If phase is set, use it
            if let phase = phase {
                return gameInfoTips[gameName]?[phase]
            }
            
            // Fallback to intro dialogue
            return gameInfoTips[gameName]?[.introDialogue]
        }
        
        // If no match found, return nil
        return nil
    }
    
    // Create an info popup for the current view and phase
    func createInfoPopup(for view: String, phase: GamePhase? = nil, onButtonTap: @escaping () -> Void) -> InfoPopup? {
        // Get appropriate tip based on view and phase
        let tip = getTip(for: view, phase: phase) ?? LocalizedStringResource(stringLiteral:
            "Welcome to \(GameConstants.gameTitle)! This informational popup provides context about your current screen.")
        
        let title = getTitleForInfo(view: view, phase: phase)
        
        return InfoPopup(
            title: LocalizedStringResource(stringLiteral: title),
            message: tip,
            buttonTitle: "Got it!",
            onButtonTap: onButtonTap
        )
    }
}
