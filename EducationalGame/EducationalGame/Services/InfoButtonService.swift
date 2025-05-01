import Foundation
import SwiftUI

// Service for providing contextual information throughout the app
class InfoButtonService {
    // Shared instance for easy access
    static let shared = InfoButtonService()
    
    // Store predefined tip content for different views and phases
    private let gameInfoTips: [String: [GamePhase: LocalizedStringResource]] = [
        String(localized: GameConstants.miniGames[0].name): [
            .introDialogue: "Learning about binary numbers helps you understand how computers store and process all data. Each digit in binary (0 or 1) represents an electrical signal being off or on.",
            .questions: "Test your understanding of binary concepts. Remember that each position in a binary number represents a power of 2, starting from the right.",
            .exploration: "Explore converting between binary and decimal. In binary, each position represents a power of 2: 1, 2, 4, 8, 16, etc.",
            .tutorialDialogue: "Binary numbers build by doubling each position's value as you move left. This is efficient for computers because they work with electrical signals that are either on or off.",
            .noviceChallenge: "Practice converting decimal numbers to binary. Remember to find the largest power of 2 that fits, then work your way down.",
            .apprenticeChallenge: "Keep practicing with larger numbers. Think of binary conversion as finding which powers of 2 add up to your decimal number.",
            .adeptChallenge: "You're becoming quite skilled! Binary is the foundation for all digital information, from text to images to videos.",
            .lastDialogue: "Your binary armband will represent your birthday in a unique code that you'll understand but others might not!",
            .expertChallenge: "This final challenge puts all your binary knowledge to work. You're thinking like a computer now!",
            .review: "Review what you've learned about binary numbers and their role in computing. These concepts apply to all digital technology.",
            .reward: "Congratulations on mastering binary! This knowledge is fundamental to understanding how computers work at their most basic level."
        ],
        String(localized: GameConstants.miniGames[1].name): [
            .introDialogue: "Pixels are the building blocks of all digital images. Even the most complex pictures are just collections of these tiny colored squares.",
            .questions: "Understanding how images are stored as pixels helps you see how computers represent visual information in a way they can process.",
            .exploration: "Explore how arranging black and white pixels can create recognizable images. This is the simplest form of digital art.",
            .noviceChallenge: "Try creating a simple image using an 8×8 grid. Think of each cell as a pixel that can be either on or off.",
            .tutorialDialogue: "A larger grid means more detail is possible, but also requires more data to store. This is the trade-off between image quality and file size.",
            .apprenticeChallenge: "The 16×16 grid gives you four times as many pixels as the 8×8 grid. Notice how much more detail you can include.",
            .adeptChallenge: "Run-Length Encoding (RLE) compresses images by storing repeating patterns more efficiently.",
            .expertChallenge: "Challenge yourself to create images that can be efficiently compressed while still looking good.",
            .review: "Binary images and compression techniques are foundational concepts in digital graphics and computer vision.",
            .reward: "You now understand how computers store and compress images - a key concept in digital media technology!"
        ],
        String(localized: GameConstants.miniGames[2].name): [
            .introDialogue: "Digital colors work differently from paint. On screens, colors are created by mixing red, green, and blue light in different amounts.",
            .questions: "Test your understanding of how the RGB color model works and how computers create millions of colors from just three primary ones.",
            .exploration: "Experiment with RGB values to create different colors. Try to predict what color will result from various combinations.",
            .tutorialDialogue: "Hexadecimal (hex) color codes are a shorthand way to write RGB values. Each pair of characters represents red, green, or blue.",
            .noviceChallenge: "Practice creating colors using RGB sliders and observe how the hex code changes accordingly.",
            .lastDialogue: "Opacity (or alpha) controls how transparent a color appears. This allows for effects like see-through objects and smooth transitions.",
            .apprenticeChallenge: "Use hex codes to precisely specify colors. Web developers and digital designers use these codes extensively.",
            .adeptChallenge: "Experiment with opacity to create layered effects. This concept is crucial in UI design and digital art.",
            .expertChallenge: "Combine your knowledge of color and transparency to solve complex challenges.",
            .review: "Review what you've learned about digital colors, hex codes, and opacity. These concepts are used in all digital media.",
            .reward: "Congratulations! You now understand how computers display and manipulate colors - essential knowledge for digital design."
        ]
    ]
    
    // Specific tips for views without phases
    private let nonPhaseViewTips: [String: LocalizedStringResource] = [
        "Main Menu": "Welcome to \(GameConstants.gameTitle)! Choose a mini-game to start learning about computer science concepts in a fun way.",
        "Achievements": "Here you can see your progress and achievements. Complete mini-games and challenges to unlock more achievements!"
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
        // Handle main menu case
        if view == GameConstants.gameTitle || view == "Main Menu" {
            return nonPhaseViewTips["Main Menu"]
        }
        
        // Handle achievements case
        if view == "Achievements" {
            return nonPhaseViewTips["Achievements"]
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
