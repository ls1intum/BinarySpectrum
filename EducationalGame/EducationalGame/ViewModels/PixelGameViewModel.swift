import Foundation
import SwiftUICore

@Observable class PixelGameViewModel: ObservableObject {
    // Game State
    var currentPhase: GamePhase = .intro
    var blackCells: Set<Int> = [] // Stores the black squares
    var progress: Double = 0.0
    var hintShown: Bool = false
    var hintMessage: String = ""
    var isCorrect: Bool = false
    
    // Game Config
    let gridSize = 8
    let cellSize: CGFloat = 30
    let penaltyFactor: Double = 0.05 // Decrease progress by 5% for each wrong action
    
    // Game Content
    let introDialogue = [
        "Welcome to Pixel Decoder!",
        "In this game, you'll decode binary representations into images.",
        "Each '1' represents a black pixel, and each '0' represents a white pixel.",
        "Your job is to create the correct image by turning pixels black or white."
    ]
    
    let introQuestions: [Question] = [
        Question(
            question: "What is the main advantage of using binary (black and white) images?",
            alternatives: [
                1: "They are more colorful",
                2: "They require less storage space",
                3: "They are easier to create"
            ],
            correctAnswer: 2,
            explanation: "Binary images use only 1 bit per pixel (0 or 1), making them very efficient in terms of storage space compared to color images."
        ),
        Question(
            question: "What type of images are often represented using binary patterns?",
            alternatives: [
                1: "Photographs",
                2: "Simple icons and symbols",
                3: "Gradient images"
            ],
            correctAnswer: 2,
            explanation: "Binary patterns are commonly used for simple icons, symbols, and basic shapes where only black and white are needed."
        )
    ]
    
    var codeToDecrypt: String = """
    00000000
    00000110
    00100110
    00000000
    00000000
    01000010
    00111100
    00000000
    """
    
    private var correctCells: Set<Int> = [] // Stores cells that should be black (where binary is 1)
    private var whiteCells: Set<Int> = [] // Stores cells that should be white (where binary is 0)
    
    init() {
        generateCellSets()
    }
    
    private func generateCellSets() {
        correctCells.removeAll()
        whiteCells.removeAll()
        
        // Parse the binary code to determine which cells should be black or white
        let rows = codeToDecrypt.split(separator: "\n")
        for (rowIndex, row) in rows.enumerated() {
            for (colIndex, char) in row.enumerated() {
                let cellIndex = rowIndex * gridSize + colIndex
                if char == "1" {
                    correctCells.insert(cellIndex)  // Cells that should be black
                } else {
                    whiteCells.insert(cellIndex)    // Cells that should be white
                }
            }
        }
    }
    
    func toggleCell(_ index: Int) {
        // If hint is shown, don't allow changes
        if hintShown { return }
        
        let wasBlack = blackCells.contains(index)
        
        // Toggle the cell's state
        if wasBlack {
            blackCells.remove(index)
        } else {
            blackCells.insert(index)
        }
        
        // Calculate the progress after the change
        calculateProgress()
    }
    
    private func calculateProgress() {
        // Count correctly filled black cells (where binary is 1)
        let correctBlackCells = blackCells.intersection(correctCells).count
        
        // Count incorrectly filled black cells (where binary is 0)
        let incorrectBlackCells = blackCells.intersection(whiteCells).count
        
        // Calculate progress percentage based on correct black cells
        let correctPercentage = Double(correctBlackCells) / Double(correctCells.count)
        
        // Calculate penalty based on incorrect black cells
        let penalty = Double(incorrectBlackCells) * penaltyFactor
        
        // Calculate final progress (capped between 0 and 1)
        progress = max(0.0, min(1.0, correctPercentage - penalty))
    }
    
    func checkAnswer() {
        // The answer is correct when all and only the correct cells are black
        let allCorrectBlack = correctCells.isSubset(of: blackCells)
        let noIncorrectBlack = blackCells.intersection(whiteCells).isEmpty
        
        isCorrect = allCorrectBlack && noIncorrectBlack
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded the image!"
            progress = 1.0
        } else {
            if progress > 0.8 {
                hintMessage = "You're very close! Just a few more adjustments needed."
            } else if progress > 0.5 {
                hintMessage = "Good progress, but there are still errors in your solution."
            } else {
                hintMessage = "Keep trying! Remember: 1 = black pixel, 0 = white pixel."
            }
        }
        
        hintShown = true
    }
    
    func hideHint() {
        hintShown = false
    }
    
    func resetGame() {
        blackCells.removeAll()
        progress = 0.0
        hintShown = false
        hintMessage = ""
        isCorrect = false
        currentPhase = .intro
        
        // Generate a new pattern
        generateRandomPattern()
        generateCellSets()
    }
    
    private func generateRandomPattern() {
        // This would generate a new random pattern
        // For now, we'll just keep the existing pattern
    }
    
    // Format the code to display in rows
    var formattedCode: String {
        return codeToDecrypt
            .replacingOccurrences(of: "0", with: " 0")
            .replacingOccurrences(of: "1", with: " 1")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "\n ")
    }
}
