import Foundation
import SwiftUI

@Observable class ColorGameViewModel: ObservableObject {
    let gameType = "Color Game"
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
        let increasesOpacity: Bool
    }
    
    // Challenge properties
    private var tolerance: Double = 0.15 // Increased tolerance for more forgiving color matching
    var timeRemaining: Int = 60
    var attemptsRemaining: Int = 5
    private var timer: Timer?
    
    // Game Content from GameConstants
    var introDialogue: [String] { GameConstants.ColorGameContent.introDialogue }
    var hexLearningDialogue: [String] { GameConstants.ColorGameContent.hexLearningDialogue }
    var opacityLearningDialogue: [String] { GameConstants.ColorGameContent.opacityLearningDialogue }
    var introQuestions: [Question] { GameConstants.ColorGameContent.introQuestions }
    var reviewCards: [ReviewCard] { GameConstants.ColorGameContent.reviewCards }
    
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
        
        let wordArray = Array(currentWord)

        for row in 0..<4 {
            var rowSquares: [AlphaSquare] = []
            for col in 0..<4 {
                let index = row * 4 + col
                let letter = index < wordArray.count ? String(wordArray[index]) : ""
                let baseAlpha = letter.isEmpty ? Double.random(in: 0.1...0.4) : Double.random(in: 0.3...0.7)
                let increasesOpacity = Bool.random()
        
                rowSquares.append(AlphaSquare(baseAlpha: baseAlpha, letter: letter, increasesOpacity: increasesOpacity))
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
    
    // Complete a game stage and advance to next phase
    func completeGame(score: Int, percentage: Double) {
        // Record completion using the shared userViewModel
        sharedUserViewModel.completeMiniGame("Color Game - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
        
        // Advance to next phase locally
        var nextPhase = currentPhase
        nextPhase.next(for: gameType)
        currentPhase = nextPhase
    }
    
    init() {
        // Initialize the alpha grid
        setupAlphaGrid()
        
        // Listen for reset notifications
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
    
    @objc func resetGameState() {
        // Reset game to initial state
        currentPhase = .intro
        red = 0.5
        green = 0.5
        blue = 0.5
        alpha = 1.0
        showHint = false
        isCorrect = false
        hintMessage = ""
        setupAlphaGrid() // Reset the grid
    }
    
    private func setupAlphaGrid() {
        // Initialize or reset the alpha grid
        // This is a placeholder for your actual implementation
        alphaGrid = []
        
        // Pick a random word from hiddenWords
        currentWord = hiddenWords.randomElement() ?? "SWIFT"
    }
}
