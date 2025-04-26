import Foundation
import SwiftUICore

@Observable class PixelGameViewModel: ObservableObject {
    let gameType = "Pixel Game"
    var currentPhase: GamePhase = .intro

    var blackCells: Set<Int> = [] // Stores the black squares
    var progress: Double = 0.0
    var hintShown: Bool = false
    var hintMessage: String = ""
    var isCorrect: Bool = false
    
    // RLE Challenge
    var rleCode: String = """
    W2B4W2
    W1B6W1
    B2W1B2W1B2
    B2W1B2W1B2
    B8
    B2W1B2W1B2
    W1B2W2B2W1
    W2B4W2
    """
    
    // Game Config
    let gridSize = 8
    let cellSize: CGFloat = 30
    
    // Game Content from GameConstants
    var introDialogue: [String] { GameConstants.PixelGameContent.introDialogue }
    var secondDialogue: [String] { GameConstants.PixelGameContent.secondDialogue }
    var thirdDialogue: [String] { GameConstants.PixelGameContent.thirdDialogue }
    var rleDialogue: [String] { GameConstants.PixelGameContent.rleDialogue }
    var introQuestions: [Question] { GameConstants.PixelGameContent.introQuestions }
    var reviewCards: [(title: String, content: String, example: String)] { GameConstants.PixelGameContent.reviewCards }
    
    // Binary Encoding Challenge
    let encodingChallengeGrid: Set<Int> = [
        9, 10, 11, 12, 13, 14, // First row of black pixels
        17, 22, // Second row
        25, 30, // Third row
        33, 38, // Fourth row
        41, 46, // Fifth row
        49, 50, 51, 52, 53, 54 // Last row of black pixels
    ]
    
    var playerBinaryCode: String = ""
    
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
        blackCells.removeAll()
        progress = 0.0
        hintShown = false
        hintMessage = ""
        isCorrect = false
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
                    correctCells.insert(cellIndex) // Cells that should be black
                } else {
                    whiteCells.insert(cellIndex) // Cells that should be white
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
        
        // Calculate progress percentage based on correct black cells
        let correctPercentage = Double(correctBlackCells) / Double(correctCells.count)
        
        // Calculate penalty based on incorrect black cells
        
        // Calculate final progress (capped between 0 and 1)
        progress = max(0.0, min(1.0, correctPercentage))
    }
    
    func checkBinaryEncoding() {
        // Convert the challenge grid to binary string
        let correctBinary = convertGridToBinary(encodingChallengeGrid)
        
        // Normalize both strings (remove spaces and newlines)
        let normalizedPlayerCode = playerBinaryCode.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        let normalizedCorrectCode = correctBinary.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        
        isCorrect = normalizedPlayerCode == normalizedCorrectCode
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully encoded the image in binary!"
            progress = 1.0
            currentPhase = .tutorial // Move to RLE tutorial
        } else {
            if normalizedPlayerCode.count == normalizedCorrectCode.count {
                hintMessage = "Almost there! Check your 1's and 0's carefully."
            } else {
                hintMessage = "The length of your code doesn't match. Remember: 8 bits per row!"
            }
        }
        
        hintShown = true
    }
    
    private func convertGridToBinary(_ grid: Set<Int>) -> String {
        var binaryString = ""
        
        for row in 0..<gridSize {
            var rowString = ""
            for col in 0..<gridSize {
                let index = row * gridSize + col
                rowString += grid.contains(index) ? "1" : "0"
            }
            binaryString += rowString + "\n"
        }
        
        return binaryString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func checkAnswer() {
        // The answer is correct when all and only the correct cells are black
        let allCorrectBlack = correctCells.isSubset(of: blackCells)
        let noIncorrectBlack = blackCells.intersection(whiteCells).isEmpty
        
        isCorrect = allCorrectBlack && noIncorrectBlack
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded the image!"
            progress = 1.0
            currentPhase = .exploration // Move to binary encoding challenge
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
    
    func checkRLEAnswer() {
        // Convert the current grid state to RLE format
        let currentRLE = convertGridToRLE()
        
        // Compare with the target RLE
        isCorrect = currentRLE == rleCode
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded the RLE image!"
            progress = 1.0
            currentPhase = .reward
        } else {
            if progress > 0.8 {
                hintMessage = "You're very close! Just a few more adjustments needed."
            } else if progress > 0.5 {
                hintMessage = "Good progress, but there are still errors in your solution."
            } else {
                hintMessage = "Keep trying! Remember: W means white pixels, B means black pixels, and the number tells you how many!"
            }
        }
        
        hintShown = true
    }
    
    private func convertGridToRLE() -> String {
        var rleLines: [String] = []
        
        // Process each row
        for row in 0..<gridSize {
            var currentLine = ""
            var currentColor: Character = "W"
            var count = 0
            
            // Process each column in the row
            for col in 0..<gridSize {
                let index = row * gridSize + col
                let isBlack = blackCells.contains(index)
                let color: Character = isBlack ? "B" : "W"
                
                if color == currentColor {
                    count += 1
                } else {
                    // Add the previous run to the line
                    currentLine += "\(currentColor)\(count)"
                    currentColor = color
                    count = 1
                }
            }
            
            // Add the last run of the line
            currentLine += "\(currentColor)\(count)"
            rleLines.append(currentLine)
        }
        
        return rleLines.joined(separator: "\n")
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
    
    // Complete a game stage and advance to next phase
    func completeGame(score: Int, percentage: Double) {
        // Record completion using the shared userViewModel
        sharedUserViewModel.completeMiniGame("Pixel Game - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
    }
}
