import Foundation
import SwiftUI

@Observable class ColorGameViewModel: ObservableObject {
    var currentPhase = GamePhase.intro
    
    // Game State
    var red: Double = 0.5
    var green: Double = 0.5
    var blue: Double = 0.5
    var alpha: Double = 1.0
    var targetColor: Color = .clear
    var targetAlpha: Double = 1.0
    var showHint = false
    var isCorrect = false
    var hintMessage = ""
    
    // Game Content
    let introDialogue = [
        "Welcome to the Color Game!",
        "In this game, you'll learn how computers create colors using RGB values.",
        "Every color you see on a screen is made by mixing Red, Green, and Blue light.",
        "Your mission is to understand and master RGB color mixing!"
    ]
    
    let hexLearningDialogue = [
        "As you adjust the Red, Green, and Blue sliders, you might have noticed a strange code appearing below your color… something like #1A73E8.",
        "That's not just a random mix of letters and numbers—it's the hexadecimal (or hex) code for your color! But what does it mean?",
        "Hex is a shortcut computers use to store colors more efficiently. Instead of long binary numbers, hex uses six characters—made up of numbers (0-9) and letters (A-F)—to represent RGB values.",
        "But instead of writing long binary numbers, computers use hex, which groups every 4 bits into a single digit!"
    ]
    
    let opacityLearningDialogue = [
        "You've mastered RGB and Hex colors, but have you noticed something missing? In real-world digital images, colors don't just appear solid—they can be transparent or semi-transparent!",
        "This is where opacity (or alpha) comes in! Opacity controls how much you can 'see through' a color.",
        "Think of it like painting with watercolors—if you add more water, the color becomes lighter and blends with the background. In digital colors, we use an extra number (A for Alpha) to do the same thing!"
    ]
    
    let introQuestions: [Question] = [
        Question(
            question: "What does RGB stand for in digital colors?",
            alternatives: [
                1: "Really Good Blue",
                2: "Red, Green, Blue",
                3: "Rainbow Gradient Blend"
            ],
            correctAnswer: 2
        ),
        Question(
            question: "What color do you get when you mix Red and Blue at maximum values?",
            alternatives: [
                1: "Purple",
                2: "Brown",
                3: "Orange"
            ],
            correctAnswer: 1
        ),
        Question(
            question: "What happens when you mix all RGB colors at maximum values?",
            alternatives: [
                1: "Black",
                2: "Gray",
                3: "White"
            ],
            correctAnswer: 3
        )
    ]
    
    // Challenge properties
    private var tolerance: Double = 0.15 // Increased tolerance for more forgiving color matching
    
    // MARK: - Game Logic
    
    func generateNewTargetColor(includeAlpha: Bool = false) {
        targetColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
        if includeAlpha {
            targetAlpha = Double.random(in: 0.2...0.8) // Avoid extremes for better visibility
        }
    }
    
    func checkColorMatch() {
        let currentColor = Color(red: red, green: green, blue: blue)
        var difference = colorDifference(current: currentColor, target: targetColor)
        
        if case .challenges = currentPhase {
            if showingOpacity {
                // For opacity, we want to be a bit more strict but still allow some tolerance
                let alphaDifference = abs(alpha - targetAlpha)
                difference = max(difference, alphaDifference * 2) // Weight opacity differences more heavily
            }
        }
        
        isCorrect = difference <= tolerance
        showHint = true
        
        if isCorrect {
            hintMessage = "Great job! The colors match well!"
        } else {
            if difference <= tolerance * 1.5 {
                hintMessage = "Very close! Just need a tiny adjustment."
            } else if difference <= tolerance * 2 {
                hintMessage = "Getting there! Try adjusting the sliders a bit more."
            } else {
                var hint = "Try comparing the colors carefully. "
                if red > targetRed + tolerance { hint += "Less red. " }
                else if red < targetRed - tolerance { hint += "More red. " }
                if green > targetGreen + tolerance { hint += "Less green. " }
                else if green < targetGreen - tolerance { hint += "More green. " }
                if blue > targetBlue + tolerance { hint += "Less blue. " }
                else if blue < targetBlue - tolerance { hint += "More blue. " }
                hintMessage = hint
            }
        }
    }
    
    func hideHint() {
        showHint = false
        hintMessage = ""
    }
    
    func resetGame() {
        red = 0.5
        green = 0.5
        blue = 0.5
        alpha = 1.0
        showHint = false
        isCorrect = false
        hintMessage = ""
        currentPhase = .intro
    }
    
    // MARK: - Helper Functions
    
    private func colorDifference(current: Color, target: Color) -> Double {
        var currentRed: CGFloat = 0
        var currentGreen: CGFloat = 0
        var currentBlue: CGFloat = 0
        var targetRed: CGFloat = 0
        var targetGreen: CGFloat = 0
        var targetBlue: CGFloat = 0
        
        UIColor(current).getRed(&currentRed, green: &currentGreen, blue: &currentBlue, alpha: nil)
        UIColor(target).getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: nil)
        
        let redDiff = abs(currentRed - targetRed)
        let greenDiff = abs(currentGreen - targetGreen)
        let blueDiff = abs(currentBlue - targetBlue)
        
        return (redDiff + greenDiff + blueDiff) / 3.0
    }
    
    var currentColorHex: String {
        String(format: "#%02X%02X%02X",
               Int(red * 255),
               Int(green * 255),
               Int(blue * 255))
    }
    
    var targetColorHex: String {
        var targetRed: CGFloat = 0
        var targetGreen: CGFloat = 0
        var targetBlue: CGFloat = 0
        
        UIColor(targetColor).getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: nil)
        
        return String(format: "#%02X%02X%02X",
                     Int(targetRed * 255),
                     Int(targetGreen * 255),
                     Int(targetBlue * 255))
    }
    
    // MARK: - Game State Helpers
    
    var showingOpacity: Bool {
        // Show opacity controls in the second half of the challenges
        if case .challenges = currentPhase {
            return isCorrect
        }
        return false
    }
    
    // Helper properties for hints
    private var targetRed: Double {
        var red: CGFloat = 0
        UIColor(targetColor).getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    private var targetGreen: Double {
        var green: CGFloat = 0
        UIColor(targetColor).getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    private var targetBlue: Double {
        var blue: CGFloat = 0
        UIColor(targetColor).getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
}
