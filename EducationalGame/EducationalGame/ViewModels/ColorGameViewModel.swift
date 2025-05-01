import Foundation
import SwiftUI

@Observable class ColorGameViewModel: ObservableObject {
    let gameType = "Color Game"
    var currentPhase = GamePhase.intro
    
    // MARK: - Game State
    
    struct ColorState {
        var red: Double = 0.5
        var green: Double = 0.5
        var blue: Double = 0.5
        var alpha: Double = 1.0
        
        var color: Color {
            Color(red: red, green: green, blue: blue)
        }
        
        var hexString: String {
            String(format: "#%02X%02X%02X",
                   Int(red * 255),
                   Int(green * 255),
                   Int(blue * 255))
        }
        
        mutating func reset() {
            red = 0.5
            green = 0.5
            blue = 0.5
            alpha = 1.0
        }
    }
    
    struct ChallengeState {
        var targetColor: Color = .clear
        var targetAlpha: Double = 1.0
        var tolerance: Double = 0.15
        var timeRemaining: Int = 60
        private var timer: Timer?
        
        var targetHexString: String {
            var targetRed: CGFloat = 0
            var targetGreen: CGFloat = 0
            var targetBlue: CGFloat = 0
            
            UIColor(targetColor).getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: nil)
            
            return String(format: "#%02X%02X%02X",
                          Int(targetRed * 255),
                          Int(targetGreen * 255),
                          Int(targetBlue * 255))
        }
        
        var targetComponents: (red: Double, green: Double, blue: Double) {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            
            UIColor(targetColor).getRed(&red, green: &green, blue: &blue, alpha: nil)
            return (Double(red), Double(green), Double(blue))
        }
        
        mutating func startTimer() { // TODO: remove?
            stopTimer()
        }
        
        mutating func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        mutating func reset() {
            targetColor = .clear
            targetAlpha = 1.0
            timeRemaining = 60
            stopTimer()
        }
    }
    
    struct AlphaChallengeState {
        var opacityValue: Double = 0.5
        var userAnswer: String = ""
        var showSuccess: Bool = false
        var grid: [[AlphaSquare]] = []
        private let hiddenWords = ["SWIFT", "COLOR", "ALPHA", "PIXEL", "GAME"]
        private var currentWord: String = ""
        
        struct AlphaSquare {
            let baseAlpha: Double
            let letter: String
            let increasesOpacity: Bool
        }
        
        mutating func generateNewGrid() {
            currentWord = hiddenWords.randomElement() ?? "SWIFT"
            grid = []
            
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
                grid.append(rowSquares)
            }
            
            opacityValue = 0.5
            userAnswer = ""
            showSuccess = false
        }
        
        func checkAnswer() -> (isCorrect: Bool, message: LocalizedStringResource) {
            let normalizedAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if normalizedAnswer == currentWord {
                return (true, "Correct! Well done! 🎉")
            } else {
                return (false, "Try adjusting the opacity to see the letters more clearly!")
            }
        }
    }
    
    struct ReversedChallengeState {
        var targetColor: Color = .clear
        var targetAlpha: Double = 1.0
        var options: [Color] = []
        var correctOptionIndex: Int = 0
        var selectedOptionIndex: Int? = nil
        
        var targetHexString: String {
            var targetRed: CGFloat = 0
            var targetGreen: CGFloat = 0
            var targetBlue: CGFloat = 0
            
            UIColor(targetColor).getRed(&targetRed, green: &targetGreen, blue: &targetBlue, alpha: nil)
            
            return String(format: "#%02X%02X%02X",
                          Int(targetRed * 255),
                          Int(targetGreen * 255),
                          Int(targetBlue * 255))
        }
        
        mutating func generateNewChallenge() {
            // Generate a random target color with alpha
            let targetRed = Double.random(in: 0...1)
            let targetGreen = Double.random(in: 0...1)
            let targetBlue = Double.random(in: 0...1)
            
            targetColor = Color(red: targetRed, green: targetGreen, blue: targetBlue)
            targetAlpha = Double.random(in: 0.2...0.8)
            
            // Generate three options, one being the correct one
            options = []
            correctOptionIndex = Int.random(in: 0...2)
            
            for i in 0...2 {
                if i == correctOptionIndex {
                    options.append(targetColor.opacity(targetAlpha))
                } else {
                    let similarColor = Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
                    options.append(similarColor.opacity((targetAlpha + Double(i + 1) * 0.3).truncatingRemainder(dividingBy: 1)))
                }
            }
            selectedOptionIndex = nil
        }
        
        func checkAnswer(selectedIndex: Int) -> (isCorrect: Bool, message: LocalizedStringResource) {
            if selectedIndex == correctOptionIndex {
                return (true, "Correct! You've matched the color perfectly!")
            } else {
                return (false, "Not quite! Try comparing the colors more carefully.")
            }
        }
    }
    
    // MARK: - State Properties
    
    var currentColor = ColorState()
    var challengeState = ChallengeState()
    var alphaChallengeState = AlphaChallengeState()
    var reversedChallengeState = ReversedChallengeState()
    
    // MARK: - UI State
    
    var showHint = false
    var isCorrect = false
    var hintMessage: LocalizedStringResource = ""
    
    // MARK: - Game Content
    
    var introDialogue: [LocalizedStringResource] { GameConstants.ColorGameContent.introDialogue }
    var hexLearningDialogue: [LocalizedStringResource] { GameConstants.ColorGameContent.hexDialogue }
    var opacityLearningDialogue: [LocalizedStringResource] { GameConstants.ColorGameContent.opacityDialogue }
    var introQuestions: [Question] { GameConstants.ColorGameContent.introQuestions }
    var reviewCards: [ReviewCard] { GameConstants.ColorGameContent.reviewCards }
    var rewardMessage: LocalizedStringResource { GameConstants.ColorGameContent.rewardMessage }
    
    // MARK: - Game Logic
    
    func generateNewTargetColor(includeAlpha: Bool = false) {
        challengeState.targetColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
        if includeAlpha {
            challengeState.targetAlpha = Double.random(in: 0.2...0.8)
        }
    }
    
    func checkColorMatch() -> (isCorrect: Bool, message: LocalizedStringResource) {
        let colorDiff = colorDifference(current: currentColor.color, target: challengeState.targetColor)
        let alphaDiff = abs(currentColor.alpha - challengeState.targetAlpha)
        let totalDiff = max(colorDiff, alphaDiff * 2)
    
        let isMatch = totalDiff <= challengeState.tolerance
    
        if isMatch {
            return (true, "Great job! The colors match well!")
        } else {
            var hints: [LocalizedStringResource] = []
            let target = challengeState.targetComponents
        
            if currentColor.red > target.red + challengeState.tolerance {
                hints.append("Less red.")
            } else if currentColor.red < target.red - challengeState.tolerance {
                hints.append("More red.")
            }

            if currentColor.green > target.green + challengeState.tolerance {
                hints.append("Less green.")
            } else if currentColor.green < target.green - challengeState.tolerance {
                hints.append("More green.")
            }

            if currentColor.blue > target.blue + challengeState.tolerance {
                hints.append("Less blue.")
            } else if currentColor.blue < target.blue - challengeState.tolerance {
                hints.append("More blue.")
            }

            if currentColor.alpha > challengeState.targetAlpha + challengeState.tolerance {
                hints.append("Less opacity.")
            } else if currentColor.alpha < challengeState.targetAlpha - challengeState.tolerance {
                hints.append("More opacity.")
            }

            let combined = "Try comparing the colors carefully. " + hints.map { String(localized: $0) }.joined(separator: " ")
            return (false, LocalizedStringResource(stringLiteral: combined))
        }
    }

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
    
    func completeGame(score: Int, percentage: Double) {
        sharedUserViewModel.completeMiniGame("\(gameType) - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
        currentPhase.next(for: gameType)
        currentColor.reset()
    }
    
    func nextPhase() {
        currentPhase.next(for: gameType)
        currentColor.reset()
    }
    
    func resetGame() {
        currentPhase = .intro
        currentColor.reset()
        challengeState.reset()
        alphaChallengeState.generateNewGrid()
        reversedChallengeState.generateNewChallenge()
        showHint = false
        isCorrect = false
        hintMessage = ""
    }
    
    init() {
        alphaChallengeState.generateNewGrid()
        reversedChallengeState.generateNewChallenge()
        
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
        resetGame()
    }
}
