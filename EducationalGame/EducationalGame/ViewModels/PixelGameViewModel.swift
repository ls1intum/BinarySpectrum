import Foundation
import SwiftUI

@Observable class PixelGameViewModel: ObservableObject {
    let gameType = "Pixel Game"
    var currentPhase: GamePhase = .introDialogue

    // MARK: - Expert Challenge State
    
    var artName: String = ""
    var compressionText: String = ""
    var compressionRatio: Double = 0
    var compressionScore: Int = 0
    var showSaveSuccess: Bool = false
    var savedArtString: String = ""
    
    // MARK: - Adept Challenge State
    
    var hexOutput: String = ""
    var selectedArt: String = "None"
    
    struct AdeptState {
        var currentArtIndex: Int = 0
        var correctCells: Set<Int> = []
        var hintRevealedCells: Set<Int> = []
        
        mutating func loadRandomArt() {
            let previousIndex = currentArtIndex
            // Randomly choose a different art
            repeat {
                currentArtIndex = Int.random(in: 0..<GameConstants.pixelArt16x16.count)
            } while currentArtIndex == previousIndex && GameConstants.pixelArt16x16.count > 1
            
            updateCorrectCells()
        }
        
        // Load a random art ensuring it's different from the specified 8x8 art name
        mutating func loadRandomArt(differentFrom smallArtName: String) {
            let previousIndex = currentArtIndex
            
            // Try to find an art with a different name than the 8x8 art
            var attempts = 0
            let maxAttempts = 10 // Prevent infinite loop in case names are similar
            
            repeat {
                currentArtIndex = Int.random(in: 0..<GameConstants.pixelArt16x16.count)
                attempts += 1
                
                // If we've tried too many times, just accept any different index
                if attempts >= maxAttempts {
                    if currentArtIndex != previousIndex || GameConstants.pixelArt16x16.count <= 1 {
                        break
                    }
                }
            } while (GameConstants.pixelArt16x16[currentArtIndex].name == smallArtName || 
                    currentArtIndex == previousIndex) && 
                    GameConstants.pixelArt16x16.count > 1
            
            updateCorrectCells()
        }
        
        mutating func updateCorrectCells() {
            correctCells = GameConstants.pixelArt16x16[currentArtIndex].grid.blackPixels
            hintRevealedCells = []
        }
        
        var currentArt: PixelArt {
            GameConstants.pixelArt16x16[currentArtIndex]
        }
        
        // Format binary code for display
        var formattedBinaryCode: String {
            var binaryString = ""
            
            for row in 0..<16 {
                for col in 0..<16 {
                    let index = row * 16 + col
                    binaryString += correctCells.contains(index) ? "1" : "0"
                    
                    // Add space after each digit for better readability
                    if col < 16 - 1 {
                        binaryString += " "
                    }
                }
                if row < 16 - 1 {
                    binaryString += "\n"
                }
            }
            
            return binaryString
        }
    }
    
    var adeptState = AdeptState()
    
    // Convert grid state to a hex string
    func currentGridToHexString() -> String {
        // Create a temporary GridImage from the current black cells
        var tempGrid = GridImage(size: gridState.gridSize)
        for index in gridState.blackCells {
            let position = tempGrid.position(from: index)
            if position.row < gridState.gridSize && position.column < gridState.gridSize {
                tempGrid.setValue(true, at: position.row, column: position.column)
            }
        }
        return tempGrid.toHexString()
    }
    
    // Save the current art
    func saveArt() {
        savedArtString = currentGridToHexString()
        showSaveSuccess = true
        
        // Hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showSaveSuccess = false
        }
    }
    
    // Compresses the current art using Run-Length Encoding
    func compressCurrentArt() {
        var compressed = ""
        var uncompressedBits = 0
        var compressedBits = 0
        
        // Process the grid using run-length encoding
        for row in 0..<gridState.gridSize {
            var currentRun = 0
            var currentColor: Bool? = nil
            var rowCompression = ""
            
            for col in 0..<gridState.gridSize {
                let index = row * gridState.gridSize + col
                let isBlack = gridState.blackCells.contains(index)
                
                if currentColor == nil {
                    currentColor = isBlack
                    currentRun = 1
                } else if currentColor == isBlack {
                    currentRun += 1
                } else {
                    // End of a run, add to compressed string
                    rowCompression += (currentColor! ? "B" : "W") + "\(currentRun)"
                    
                    // Update bits count
                    uncompressedBits += currentRun
                    compressedBits += countBitsForRLE(currentRun, isBlack: currentColor!)
                    
                    // Start a new run
                    currentColor = isBlack
                    currentRun = 1
                }
            }
            
            // Add the last run in the row
            if currentColor != nil {
                rowCompression += (currentColor! ? "B" : "W") + "\(currentRun)"
                
                // Update bits count
                uncompressedBits += currentRun
                compressedBits += countBitsForRLE(currentRun, isBlack: currentColor!)
            }
            
            compressed += rowCompression + "\n"
        }
        
        compressionText = compressed
        
        // Calculate compression ratio and score
        if compressedBits > 0 {
            compressionRatio = Double(uncompressedBits) / Double(compressedBits)
            
            // Calculate a score based on compression ratio, modified by pattern complexity
            let blackPixelCount = gridState.blackCells.count
            let totalPixels = gridState.gridSize * gridState.gridSize
            let blackRatio = Double(blackPixelCount) / Double(totalPixels)
            
            // Penalize if the image is too simple (mostly black or mostly white)
            let complexityFactor = 1.0 - abs(blackRatio - 0.5) * 2.0
            
            // Combine compression ratio with complexity for final score
            compressionScore = Int(min(100, (compressionRatio * 20.0) * complexityFactor * complexityFactor))
        } else {
            compressionRatio = 1.0
            compressionScore = 0
        }
    }
    
    // Count bits required to represent a run using RLE
    private func countBitsForRLE(_ runLength: Int, isBlack: Bool) -> Int {
        // In real RLE, this would be more complex, but for educational purposes:
        // We count 1 bit for color (B/W) + bits needed for the number
        let colorBit = 1
        let countBits = max(1, Int(log2(Double(runLength))) + 1)
        return colorBit + countBits
    }
    
    // Update grid size and adjust cell size
    func updateGridSize(_ newSize: Int) {
        gridState.reset()
        gridState.gridSize = newSize
        
        // Match cell sizes with corresponding challenges
        if newSize == 8 {
            gridState.cellSize = 40 // Match novice challenge cell size
        } else {
            gridState.cellSize = 26 // Match adept challenge cell size
        }
        
        // Reset compression data when grid size changes
        compressionText = ""
        compressionRatio = 0
        compressionScore = 0
    }
    
    // MARK: - Game State
    
    struct GridState {
        var blackCells: Set<Int> = []
        var gridSize: Int = 8
        var cellSize: CGFloat = 40 // Increased for better touch targets
        var progress: Double = 0.0
        
        mutating func reset() {
            blackCells.removeAll()
            progress = 0.0
        }
    }
    
    struct DecodingState {
        var currentArtIndex: Int = 0
        var correctCells: Set<Int> = []
        
        mutating func loadRandomArt() {
            let previousIndex = currentArtIndex
            // Make sure we don't get the same art again
            repeat {
                currentArtIndex = Int.random(in: 0..<GameConstants.pixelArt8x8.count)
            } while currentArtIndex == previousIndex && GameConstants.pixelArt8x8.count > 1
            
            updateCorrectCells()
        }
        
        mutating func updateCorrectCells() {
            correctCells = GameConstants.pixelArt8x8[currentArtIndex].grid.blackPixels
        }
        
        var currentArt: PixelArt {
            GameConstants.pixelArt8x8[currentArtIndex]
        }
    }
    
    struct EncodingState {
        var playerBinaryCode: String = ""
        var currentArtIndex: Int = 0
        
        var encodingChallengeGrid: Set<Int> {
            GameConstants.pixelArt8x8[currentArtIndex].grid.blackPixels
        }
        
        mutating func loadRandomArt(differentFrom otherIndex: Int) {
            let previousIndex = currentArtIndex
            
            // Make sure we don't get the same art as the decoding challenge or the previous one
            repeat {
                currentArtIndex = Int.random(in: 0..<GameConstants.pixelArt8x8.count)
            } while (currentArtIndex == otherIndex || currentArtIndex == previousIndex) && GameConstants.pixelArt8x8.count > 2
            
            playerBinaryCode = ""
        }
        
        mutating func reset() {
            playerBinaryCode = ""
        }
    }
   
    // MARK: - State Properties
    
    var gridState = GridState()
    var decodingState = DecodingState()
    var encodingState = EncodingState()
    
    // MARK: - UI State
    
    var showHint = false
    var isCorrect = false
    var hintMessage: LocalizedStringResource = ""
    
    // MARK: - Game Content
    
    var introDialogue: [LocalizedStringResource] { GameConstants.PixelGameContent.introDialogue }
    var secondDialogue: [LocalizedStringResource] { GameConstants.PixelGameContent.secondDialogue }
    var finalDialogue: [LocalizedStringResource] { GameConstants.PixelGameContent.finalDialogue }
    var introQuestions: [Question] { GameConstants.PixelGameContent.introQuestions }
    var reviewCards: [ReviewCard] { GameConstants.PixelGameContent.reviewCards }
    var rewardMessage: LocalizedStringResource { GameConstants.PixelGameContent.rewardMessage }
    
    // MARK: - Game Logic
    
    init() {
        // Initialize with random art selections
        decodingState.loadRandomArt()
        setupEncodingChallenge() // Initialize encoding challenge
        
        // Initialize adept state with different art than novice challenge
        let noviceArtName = decodingState.currentArt.name
        adeptState.loadRandomArt(differentFrom: noviceArtName)
        
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
    
    func resetGame() {
        currentPhase = .introDialogue
        gridState.reset()
        
        // Reset with proper art separation
        decodingState.loadRandomArt()
        setupEncodingChallenge()
        
        // Reset adept challenge with different art than novice
        adeptState = AdeptState()
        let noviceArtName = decodingState.currentArt.name
        adeptState.loadRandomArt(differentFrom: noviceArtName)
        
        showHint = false
        isCorrect = false
        hintMessage = ""
        
        // Reset expert challenge properties
        artName = ""
        compressionText = ""
        compressionRatio = 0
        compressionScore = 0
        showSaveSuccess = false
        savedArtString = ""
        
        // Reset adept challenge properties
        hexOutput = ""
        selectedArt = "None"
    }
    
    func toggleCell(_ index: Int) {
        if showHint { return }
        
        // Use a very slight delay to make the animation feel more natural
        // and to prevent animation conflicts if tapping rapidly
        DispatchQueue.main.async {
            if self.gridState.blackCells.contains(index) {
                self.gridState.blackCells.remove(index)
            } else {
                self.gridState.blackCells.insert(index)
            }
            
            // Calculate progress based on the current phase/challenge
            if self.currentPhase == .adeptChallenge {
                self.calculateAdeptProgress()
            } else {
                self.calculateProgress()
            }
        }
    }
    
    private func calculateProgress() {
        let correctBlackCells = gridState.blackCells.intersection(decodingState.correctCells).count
        let incorrectBlackCells = gridState.blackCells.subtracting(decodingState.correctCells).count
        let missingBlackCells = decodingState.correctCells.count - correctBlackCells
        
        // Penalize for incorrect cells
        let totalCorrectNeeded = Double(decodingState.correctCells.count)
        let progressValue = (Double(correctBlackCells) - Double(incorrectBlackCells) * 0.5) / totalCorrectNeeded
        
        gridState.progress = max(0.0, min(1.0, progressValue))
        
        // Provide progressive hints based on progress
        if incorrectBlackCells > 5 {
            hintMessage = "You have several incorrect pixels. White spaces should remain white."
        } else if missingBlackCells > 5 {
            hintMessage = "You're missing several black pixels. Check the binary code carefully."
        } else if incorrectBlackCells > 0 {
            hintMessage = "Almost there! Check for a few incorrect pixels."
        } else if missingBlackCells > 0 {
            hintMessage = "Getting close! Just a few black pixels missing."
        } else if correctBlackCells == decodingState.correctCells.count {
            hintMessage = "Looking great! Check your work before submitting."
        } else {
            hintMessage = ""
        }
    }
    
    // Check the answer for the novice challenge
    func checkAnswer() {
        let allCorrectBlack = decodingState.correctCells.isSubset(of: gridState.blackCells)
        let noIncorrectBlack = gridState.blackCells.subtracting(decodingState.correctCells).isEmpty
        
        isCorrect = allCorrectBlack && noIncorrectBlack
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded \(decodingState.currentArt.name)!"
            gridState.progress = 1.0
        } else {
            // Calculate progress-based feedback
            let correctBlackCells = gridState.blackCells.intersection(decodingState.correctCells).count
            let incorrectBlackCells = gridState.blackCells.subtracting(decodingState.correctCells).count
            let missingBlackCells = decodingState.correctCells.count - correctBlackCells
            
            if incorrectBlackCells > 5 {
                hintMessage = "You have several incorrect pixels. White spaces should remain white."
            } else if missingBlackCells > 5 {
                hintMessage = "You're missing several black pixels. Check the binary code carefully."
            } else if incorrectBlackCells > 0 {
                hintMessage = "Almost there! Check for a few incorrect pixels."
            } else if missingBlackCells > 0 {
                hintMessage = "Getting close! Just a few black pixels missing."
            } else {
                hintMessage = "Keep trying! Remember: 1 = black pixel, 0 = white pixel."
            }
        }
    }
    
    // Generate binary representation of the current art
    var correctBinaryEncoding: String {
        let blackPixels = GameConstants.pixelArt8x8[encodingState.currentArtIndex].grid.blackPixels
        var binaryString = ""
        
        for row in 0..<gridState.gridSize {
            for col in 0..<gridState.gridSize {
                let index = row * gridState.gridSize + col
                binaryString += blackPixels.contains(index) ? "1" : "0"
                
                // Add space after each digit for better readability
                if col < gridState.gridSize - 1 {
                    binaryString += " "
                }
            }
            if row < gridState.gridSize - 1 {
                binaryString += "\n"
            }
        }
        
        return binaryString
    }
    
    // Check the binary encoding
    func checkBinaryEncoding() {
        let correctBinary = correctBinaryEncoding
        
        // Normalize both strings to compare only the 0s and 1s
        let normalizedPlayerCode = encodingState.playerBinaryCode.filter { $0 == "0" || $0 == "1" }
        let normalizedCorrectCode = correctBinary.filter { $0 == "0" || $0 == "1" }
        
        isCorrect = normalizedPlayerCode == normalizedCorrectCode
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully encoded \(GameConstants.pixelArt8x8[encodingState.currentArtIndex].name) in binary!"
            gridState.progress = 1.0
        } else {
            // Find differences for more specific feedback
            let playerRows = encodingState.playerBinaryCode.split(separator: "\n")
            let correctRows = correctBinary.split(separator: "\n")
            var errorDescription = ""
            
            let expectedDigitsPerRow = gridState.gridSize
            let playerDigitCount = normalizedPlayerCode.count
            let expectedTotalDigits = gridState.gridSize * gridState.gridSize
            
            if playerDigitCount != expectedTotalDigits {
                errorDescription = "Your code should have exactly \(expectedTotalDigits) digits total (\(expectedDigitsPerRow) per row)."
            } else if playerRows.count != gridState.gridSize {
                errorDescription = "Your code should have exactly \(gridState.gridSize) rows."
            } else {
                // Check each row for errors by comparing only the digits (0s and 1s)
                for (index, (playerRow, correctRow)) in zip(playerRows, correctRows).enumerated() {
                    let playerDigits = playerRow.filter { $0 == "0" || $0 == "1" }
                    let correctDigits = correctRow.filter { $0 == "0" || $0 == "1" }
                    
                    if playerDigits != correctDigits {
                        errorDescription = "Check row \(index + 1) - it doesn't match the image."
                        break
                    }
                }
                
                // If no specific row error was found but there's still an error
                if errorDescription.isEmpty {
                    errorDescription = "There's an error in your binary code. Double-check each row."
                }
            }
            
            hintMessage = "Almost there! \(errorDescription)\n\nStart from the top left and work row by row. Each row should have \(expectedDigitsPerRow) digits."
        }
    }
    
    // Show a popup with binary representation of the current art
    func showBinaryCompletion() {
        let binary = currentGridToBinary()
        isCorrect = true // This ensures we use the "Continue" button
        hintMessage = "This is how computers represent your image in binary:\n\n\(binary)\n\nEach 1 represents a black pixel, and each 0 represents a white pixel."
        showHint = true
    }
    
    func hideHint() {
        showHint = false
        if isCorrect {
            currentPhase.next(for: gameType)
            gridState.reset()
        }
    }
    
    // Format the code to display in rows
    var formattedCode: String {
        var formattedString = ""
        let blackPixels = GameConstants.pixelArt8x8[encodingState.currentArtIndex].grid.blackPixels
        
        for row in 0..<gridState.gridSize {
            for col in 0..<gridState.gridSize {
                let index = row * gridState.gridSize + col
                formattedString += blackPixels.contains(index) ? "1" : "0"
                
                // Add space after each digit for better readability
                if col < gridState.gridSize - 1 {
                    formattedString += " "
                }
            }
            if row < gridState.gridSize - 1 {
                formattedString += "\n"
            }
        }
        
        return formattedString
    }
    
    func completeGame(score: Int, percentage: Double) {
        sharedUserViewModel.completeMiniGame("\(gameType) - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
        currentPhase.next(for: gameType)
        gridState.reset()
    }
    
    // MARK: - Adept Challenge Functions
    
    func checkAdeptAnswer() {
        let allCorrectBlack = adeptState.correctCells.isSubset(of: gridState.blackCells)
        let noIncorrectBlack = gridState.blackCells.subtracting(adeptState.correctCells).isEmpty
        
        isCorrect = allCorrectBlack && noIncorrectBlack
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded the 16×16 image of \(adeptState.currentArt.name)!"
            gridState.progress = 1.0
        } else {
            // Create progress-based hint
            let correctBlackCells = gridState.blackCells.intersection(adeptState.correctCells).count
            let incorrectBlackCells = gridState.blackCells.subtracting(adeptState.correctCells).count
            
            // Calculate progress
            let totalCorrectNeeded = Double(adeptState.correctCells.count)
            let progressValue = (Double(correctBlackCells) - Double(incorrectBlackCells) * 0.5) / totalCorrectNeeded
            gridState.progress = max(0.0, min(1.0, progressValue))
            
            // Generate appropriate hint
            if gridState.progress > 0.8 {
                hintMessage = "You're very close! Just a few more adjustments needed."
            } else if gridState.progress > 0.5 {
                hintMessage = "Good progress, but there are still errors in your solution."
            } else {
                hintMessage = "Keep trying! The 16×16 grid is more challenging, but you can do it!\n\nNeed help? Try tapping a few more black cells based on the binary code."
            }
            
            // Give hint about getting automatic help
            if adeptState.hintRevealedCells.count < 40 {
                // Automatically reveal a few pixels to help
                let unrevealed = adeptState.correctCells.subtracting(adeptState.hintRevealedCells).subtracting(gridState.blackCells)
                let toReveal = min(5, unrevealed.count)
                
                if toReveal > 0 {
                    let randomCells = Array(unrevealed).shuffled().prefix(toReveal)
                    for cell in randomCells {
                        adeptState.hintRevealedCells.insert(cell)
                        gridState.blackCells.insert(cell)
                    }
                }
            }
        }
    }
    
    private func calculateAdeptProgress() {
        let correctBlackCells = gridState.blackCells.intersection(adeptState.correctCells).count
        let incorrectBlackCells = gridState.blackCells.subtracting(adeptState.correctCells).count
        
        // Penalize for incorrect cells
        let totalCorrectNeeded = Double(adeptState.correctCells.count)
        let progressValue = (Double(correctBlackCells) - Double(incorrectBlackCells) * 0.5) / totalCorrectNeeded
        
        gridState.progress = max(0.0, min(1.0, progressValue))
    }
    
    // Setup for novice challenge with a random 8x8 art
    func setupDecodingChallenge() {
        // Make sure we're using the correct grid size
        gridState.gridSize = 8
        gridState.cellSize = 40
        gridState.reset()
        
        // Load a random art
        decodingState.loadRandomArt()
        
        // Set an appropriate hint message explaining what to do
        hintMessage = "Decode the binary pattern on the left by tapping the grid squares to make them black (1) or white (0)."
        isCorrect = false
    }
    
    // Setup for apprentice challenge with a random 8x8 art
    func setupEncodingChallenge() {
        // Make sure we're using the correct grid size
        gridState.gridSize = 8
        gridState.cellSize = 40
        gridState.reset()
        
        // Load a random art different from the decoding challenge
        encodingState.loadRandomArt(differentFrom: decodingState.currentArtIndex)
        
        // Set an appropriate hint message explaining what to do
        isCorrect = false
    }
    
    // Setup for adept challenge with a random 16x16 art
    func setupAdeptChallenge() {
        gridState.gridSize = 16
        gridState.cellSize = 30 // Reduced cell size to make grid cells appear closer together
        gridState.reset()
  
        // Make sure we use a different art than the novice challenge
        let noviceArtName = decodingState.currentArt.name
        adeptState.loadRandomArt(differentFrom: noviceArtName)
        
        calculateAdeptProgress()
    }
    
    // Convert current grid to binary representation - used for display
    func currentGridToBinary() -> String {
        var binaryString = ""
        
        for row in 0..<gridState.gridSize {
            for col in 0..<gridState.gridSize {
                let index = row * gridState.gridSize + col
                binaryString += gridState.blackCells.contains(index) ? "1" : "0"
                
                // Add space after each digit for better readability
                if col < gridState.gridSize - 1 {
                    binaryString += " "
                }
            }
            if row < gridState.gridSize - 1 {
                binaryString += "\n"
            }
        }
        
        return binaryString
    }
}
