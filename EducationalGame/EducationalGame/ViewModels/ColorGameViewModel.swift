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
    
    // Alpha Challenge State
    var opacityValue: Double = 0.5
    var userAnswer: String = ""
    var showAlphaSuccess: Bool = false
    var alphaGrid: [[AlphaSquare]] = []
    private let hiddenWords = ["SWIFT", "COLOR", "ALPHA", "PIXEL", "GAME"]
    private var currentWord: String = ""
    
    struct AlphaSquare {
        let baseAlpha: Double
        let letter: String
    }
    
    // Challenge properties
    private var tolerance: Double = 0.15 // Increased tolerance for more forgiving color matching
    var timeRemaining: Int = 60
    var attemptsRemaining: Int = 5
    private var timer: Timer?
    
    // Game Content
    let introDialogue = [
        "Welcome to the Color Game!",
        "In this game, you'll learn how computers create colors using RGB values.",
        "Every color you see on a screen is made by mixing Red, Green, and Blue light.",
        "Your mission is to understand and master RGB color mixing!"
    ]
    
    let hexLearningDialogue = [
        "Now let's learn about hexadecimal color codes!",
        "Hex codes are a way to represent RGB values using hexadecimal numbers.",
        "Each pair of characters represents one color component:",
        "• First pair = Red (00 to FF)",
        "• Second pair = Green (00 to FF)",
        "• Third pair = Blue (00 to FF)",
        "For example, #FF0000 is pure red, #00FF00 is pure green, and #0000FF is pure blue.",
        "Ready to try matching colors using hex codes?"
    ]
    
    let opacityLearningDialogue = [
        "Now let's learn about opacity!",
        "Opacity (or alpha) controls how transparent a color is.",
        "A value of 1.0 means the color is completely solid, while 0.0 means it's completely transparent.",
        "You'll see a checkerboard pattern behind transparent colors to help you visualize the transparency.",
        "Ready to try matching colors with opacity?"
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
        
        // For opacity, we want to be a bit more strict but still allow some tolerance
        let alphaDifference = abs(alpha - targetAlpha)
        difference = max(difference, alphaDifference * 2) // Weight opacity differences more heavily
        
        isCorrect = difference <= tolerance
        showHint = true
        
        if isCorrect {
            hintMessage = "Great job! The colors match well!"
            if currentPhase == .finalChallenge {
                attemptsRemaining = 5 // Reset attempts for next challenge
            }
        } else {
            if currentPhase == .finalChallenge {
                attemptsRemaining -= 1
            }
            
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
                if alpha > targetAlpha + tolerance { hint += "Less opacity. " }
                else if alpha < targetAlpha - tolerance { hint += "More opacity. " }
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
        timeRemaining = 60
        attemptsRemaining = 5
        stopTimer()
        currentPhase = .intro
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                self.showHint = true
                self.hintMessage = "Time's up! Try again."
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
    
    // MARK: - Alpha Challenge Methods
    
    func generateNewAlphaGrid() {
        currentWord = hiddenWords.randomElement() ?? "SWIFT"
        alphaGrid = []
        
        // Create a 4x4 grid
        for row in 0..<4 {
            var rowSquares: [AlphaSquare] = []
            for col in 0..<4 {
                let index = row * 4 + col
                if index < currentWord.count {
                    // Place a letter with random base alpha
                    rowSquares.append(AlphaSquare(
                        baseAlpha: Double.random(in: 0.3...0.7),
                        letter: String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: index)])
                    ))
                } else {
                    // Empty square with random alpha
                    rowSquares.append(AlphaSquare(
                        baseAlpha: Double.random(in: 0.1...0.4),
                        letter: ""
                    ))
                }
            }
            alphaGrid.append(rowSquares)
        }
        
        // Reset state
        opacityValue = 0.5
        userAnswer = ""
        showAlphaSuccess = false
    }
    
    func checkAlphaAnswer() {
        let normalizedAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if normalizedAnswer == currentWord {
            showAlphaSuccess = true
        } else {
            hintMessage = "Try adjusting the opacity to see the letters more clearly!"
            showHint = true
        }
    }
}
