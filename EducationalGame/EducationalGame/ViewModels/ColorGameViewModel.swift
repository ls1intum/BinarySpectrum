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
    
    // Game Content
    let introDialogue = [
        "Welcome to the Digital Color Lab!",
        "Did you know? Your screen creates every color you see using just three primary colors: Red, Green, and Blue (RGB)!",
        "By mixing different amounts of these colors, computers can create millions of different colors.",
        "This is a computational thinking concept called 'decomposition' - breaking complex things (like colors) into simpler components.",
        "In this lab, you'll learn how to mix RGB values to create your own digital colors and understand how computers represent visual information!"
    ]
    
    let hexLearningDialogue = [
        "Great job mixing colors using RGB values!",
        "Now let's explore how programmers and designers write these color values using hexadecimal codes.",
        "Hex codes are a special shorthand that uses both numbers (0-9) and letters (A-F) to represent colors.",
        "Each hex code starts with # and has 6 digits: #RRGGBB",
        "• The first two digits control Red (00-FF)",
        "• The middle two control Green (00-FF)",
        "• The last two control Blue (00-FF)",
        "For example, pure red is #FF0000, pure green is #00FF00, and pure blue is #0000FF.",
        "This system is another example of 'abstraction' in computing - representing complex data in more concise ways!"
    ]
    
    let opacityLearningDialogue = [
        "Excellent work with hex codes! Now let's add another dimension to our colors: Opacity!",
        "Opacity (or alpha) controls how transparent a color is - whether you can see through it or not.",
        "It's measured from 0.0 (completely invisible) to 1.0 (completely solid).",
        "This is crucial for creating effects like shadows, glass, water, and layered interfaces.",
        "Many modern color formats add this fourth value to RGB to create 'RGBA' - where A stands for Alpha.",
        "In hex, we add two more digits: #RRGGBBAA",
        "Let's experiment with opacity values to see how they affect our colors!"
    ]
    
    let introQuestions: [Question] = [
        Question(
            question: "What computational thinking concept is being used when we break colors down into Red, Green, and Blue components?",
            alternatives: [
                1: "Pattern recognition",
                2: "Decomposition",
                3: "Algorithmic thinking",
                4: "Evaluation"
            ],
            correctAnswer: 2,
            explanation: "Breaking colors into RGB components is an example of 'decomposition' - dividing complex problems into smaller, manageable parts."
        ),
        Question(
            question: "How do computers create the color yellow on your screen?",
            alternatives: [
                1: "By using yellow pixels",
                2: "By mixing red and green light",
                3: "By removing blue from white light",
                4: "By using a special yellow filter"
            ],
            correctAnswer: 2,
            explanation: "Computers create yellow by mixing red and green light at full intensity (with no blue). This RGB value would be (255,255,0)."
        ),
        Question(
            question: "What's the purpose of hexadecimal color codes like #FF00FF?",
            alternatives: [
                1: "They look more professional in code",
                2: "They create more vibrant colors than RGB values",
                3: "They provide a shorter, standardized way to represent RGB colors",
                4: "They work better on mobile devices"
            ],
            correctAnswer: 3,
            explanation: "Hexadecimal color codes provide a concise, standardized way to represent RGB colors. The example #FF00FF represents (255,0,255) - bright magenta."
        ),
        Question(
            question: "What does the alpha (opacity) value control in RGBA colors?",
            alternatives: [
                1: "How bright the color appears",
                2: "How much the color can change over time",
                3: "How the color looks under different lighting",
                4: "How transparent or see-through the color is"
            ],
            correctAnswer: 4,
            explanation: "The alpha value controls transparency - how much you can see through a color. A value of 1.0 means completely solid, while 0.0 means completely transparent."
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
    
    // Review Cards Content
    let reviewCards: [(title: String, content: String, example: String)] = [
        (
            title: "RGB Color Model",
            content: "RGB stands for Red, Green, and Blue - the primary colors of light. By mixing these colors in different amounts, computers can create millions of colors on your screen.",
            example: "Pure Red: (255, 0, 0)\nPure Green: (0, 255, 0)\nYellow: (255, 255, 0)"
        ),
        (
            title: "Color Values",
            content: "Each RGB component ranges from 0 (none) to 255 (maximum intensity). This gives 256 possible values for each color channel.",
            example: "Black: (0, 0, 0)\nWhite: (255, 255, 255)\nPurple: (128, 0, 128)"
        ),
        (
            title: "Hexadecimal Colors",
            content: "Hex codes are a shorthand for RGB values, using base-16 numbers. Each pair of characters represents one color component (red, green, or blue).",
            example: "#FF0000 = Red\n#00FF00 = Green\n#0000FF = Blue\n#FFFFFF = White"
        ),
        (
            title: "Opacity (Alpha)",
            content: "Opacity controls how transparent a color is. Values range from 0.0 (invisible) to 1.0 (solid), allowing you to see through objects.",
            example: "Solid Blue: rgba(0,0,255,1.0)\nSemi-transparent: rgba(0,0,255,0.5)\nInvisible: rgba(0,0,255,0.0)"
        ),
        (
            title: "Color Applications",
            content: "Understanding digital color is essential for design, game development, web development, and digital art.",
            example: "User Interfaces\nDigital Artwork\nAnimations\nCoding with CSS"
        )
    ]
    
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
