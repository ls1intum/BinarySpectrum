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
            // Randomly choose a different art
            let previousIndex = currentArtIndex
            repeat {
                currentArtIndex = Int.random(in: 0..<GameConstants.pixelArt16x16.count)
            } while currentArtIndex == previousIndex && GameConstants.pixelArt16x16.count > 1
            
            updateCorrectCells()
        }
        
        mutating func updateCorrectCells() {
            correctCells = GameConstants.pixelArt16x16[currentArtIndex].grid.blackPixels
            hintRevealedCells = []
        }
        
        var currentArt: PixelArt {
            GameConstants.pixelArt16x16[currentArtIndex]
        }
        
        // Generate binary representation of the 16x16 art
        func getBinaryCode(gridSize: Int) -> String {
            var binaryString = ""
            
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    let index = row * gridSize + col
                    binaryString += correctCells.contains(index) ? "1" : "0"
                }
                binaryString += "\n"
            }
            
            return binaryString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Format binary code for display
        var formattedBinaryCode: String {
            return getBinaryCode(gridSize: 16)
                .replacingOccurrences(of: "0", with: " 0")
                .replacingOccurrences(of: "1", with: " 1")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n", with: "\n ")
        }
    }
    
    var adeptState = AdeptState()
    
    func generateHexOutput() {
        hexOutput = currentGridToHexString()
    }
    
    func clearSelectedArt() {
        selectedArt = "None"
        gridState.reset()
        hexOutput = ""
    }
    
    func selectArt(art: PixelArt) {
        selectedArt = art.name
        gridState.blackCells = art.grid.blackPixels
        gridState.gridSize = 16
        gridState.cellSize = 20
        hexOutput = currentGridToHexString()
    }
    
    func getArtByName(name: String, size: Int = 8) -> Set<Int> {
        if size == 8 {
            if let art = GameConstants.pixelArt8x8.first(where: { $0.name == name }) {
                return art.grid.blackPixels
            }
        }
        if size == 16 {
            if let art = GameConstants.pixelArt16x16.first(where: { $0.name == name }) {
                return art.grid.blackPixels
            }
        }
        return Set<Int>()
    }
    
    // Get the full PixelArt object by name and size
    func getFullArtByName(name: String, size: Int = 8) -> PixelArt? {
        if size == 8 {
            return GameConstants.pixelArt8x8.first(where: { $0.name == name })
        } else if size == 16 {
            return GameConstants.pixelArt16x16.first(where: { $0.name == name })
        }
        return nil
    }
    
    // Get a random art from the specified size collection
    func getRandomArt(size: Int = 8) -> PixelArt? {
        if size == 8 && !GameConstants.pixelArt8x8.isEmpty {
            let randomIndex = Int.random(in: 0..<GameConstants.pixelArt8x8.count)
            return GameConstants.pixelArt8x8[randomIndex]
        } else if size == 16 && !GameConstants.pixelArt16x16.isEmpty {
            let randomIndex = Int.random(in: 0..<GameConstants.pixelArt16x16.count)
            return GameConstants.pixelArt16x16[randomIndex]
        }
        return nil
    }
    
    // Convert grid state to a hex string (supports both 8x8 and 16x16 grids)
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
    
    // Load a grid from a hex string
    func loadGridFromHexString(_ hexString: String) {
        let tempGrid = GridImage(hexString: hexString)
        gridState.blackCells = tempGrid.blackPixels
        gridState.gridSize = tempGrid.size
        // Adjust cell size based on grid size
        gridState.cellSize = gridState.gridSize == 8 ? 40 : 20
    }
    
    // Save the current art to a string representation
    func saveCurrentArt() -> String {
        return currentGridToHexString()
    }
    
    // Handle the save art action
    func saveArt() {
        savedArtString = saveCurrentArt()
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
        gridState.cellSize = newSize == 8 ? 40 : 20
        
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
        
        mutating func loadNextArt() {
            currentArtIndex = (currentArtIndex + 1) % GameConstants.pixelArt8x8.count
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
        
        mutating func loadNextArt() {
            currentArtIndex = (currentArtIndex + 1) % GameConstants.pixelArt8x8.count
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
        decodingState.updateCorrectCells()
        
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
        encodingState.reset()
        decodingState.updateCorrectCells()
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
        adeptState = AdeptState()
    }
    
    func toggleCell(_ index: Int) {
        if showHint { return }
        
        if gridState.blackCells.contains(index) {
            gridState.blackCells.remove(index)
        } else {
            gridState.blackCells.insert(index)
        }
        
        // Calculate progress based on the current phase/challenge
        if currentPhase == .adeptChallenge {
            calculateAdeptProgress()
        } else {
            calculateProgress()
        }
    }
    
    private func calculateProgress() {
        let correctBlackCells = gridState.blackCells.intersection(decodingState.correctCells).count
        let incorrectBlackCells = gridState.blackCells.subtracting(decodingState.correctCells).count
        
        // Penalize for incorrect cells
        let totalCorrectNeeded = Double(decodingState.correctCells.count)
        let progressValue = (Double(correctBlackCells) - Double(incorrectBlackCells) * 0.5) / totalCorrectNeeded
        
        gridState.progress = max(0.0, min(1.0, progressValue))
    }
    
    // Setup for 16x16 art challenges
    func setup16x16Challenge() {
        gridState.gridSize = 16
        gridState.cellSize = 20 // Smaller cells for the larger grid
        gridState.reset()
        
        if let randomArt = getRandomArt(size: 16) {
            gridState.blackCells = randomArt.grid.blackPixels
        }
    }
    
    // Setup for adept challenge (16x16 hex grid)
    func checkAnswer() {
        let allCorrectBlack = decodingState.correctCells.isSubset(of: gridState.blackCells)
        let noIncorrectBlack = gridState.blackCells.subtracting(decodingState.correctCells).isEmpty
        
        isCorrect = allCorrectBlack && noIncorrectBlack
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully decoded \(decodingState.currentArt.name)!"
            gridState.progress = 1.0
            showHint = true
        } else {
            if gridState.progress > 0.8 {
                hintMessage = "You're very close! Just a few more adjustments needed."
            } else if gridState.progress > 0.5 {
                hintMessage = "Good progress, but there are still errors in your solution."
            } else {
                hintMessage = "Keep trying! Remember: 1 = black pixel, 0 = white pixel."
            }
            showHint = true
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
            }
            binaryString += "\n"
        }
        
        return binaryString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func checkBinaryEncoding() {
        let correctBinary = correctBinaryEncoding
        let normalizedPlayerCode = encodingState.playerBinaryCode.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        let normalizedCorrectCode = correctBinary.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        
        isCorrect = normalizedPlayerCode == normalizedCorrectCode
        
        if isCorrect {
            hintMessage = "Perfect! You've successfully encoded \(GameConstants.pixelArt8x8[encodingState.currentArtIndex].name) in binary!"
            gridState.progress = 1.0
            showHint = true
        } else {
            if normalizedPlayerCode.count == normalizedCorrectCode.count {
                hintMessage = "Almost there! Check your 1's and 0's carefully."
            } else {
                hintMessage = "The length of your code doesn't match. Remember: 8 bits per row!"
            }
            showHint = true
        }
    }
    
    func hideHint() {
        showHint = false
        if isCorrect {
            currentPhase.next(for: gameType)
            gridState.reset()
        }
    }
    
    func nextPhase() {
        currentPhase.next(for: gameType)
        gridState.reset()
    }
    
    // Format the code to display in rows
    var formattedCode: String {
        return correctBinaryEncoding
            .replacingOccurrences(of: "0", with: " 0")
            .replacingOccurrences(of: "1", with: " 1")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "\n ")
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
            showHint = true
        } else {
            if gridState.progress > 0.8 {
                hintMessage = "You're very close! Just a few more adjustments needed."
            } else if gridState.progress > 0.5 {
                hintMessage = "Good progress, but there are still errors in your solution."
            } else {
                hintMessage = "Keep trying! The 16×16 grid is more challenging, but you can do it!"
            }
            showHint = true
        }
    }
    
    // Show a hint by revealing a portion of the correct image
    func showAdeptHint() {
        if adeptState.hintRevealedCells.count < 40 {
            // Get some random cells from the correct set that haven't been revealed yet
            let unrevealed = adeptState.correctCells.subtracting(adeptState.hintRevealedCells)
            let toReveal = min(10, unrevealed.count)
            
            if toReveal > 0 {
                let randomCells = Array(unrevealed).shuffled().prefix(toReveal)
                for cell in randomCells {
                    adeptState.hintRevealedCells.insert(cell)
                    gridState.blackCells.insert(cell)
                }
                
                calculateAdeptProgress()
                
                hintMessage = "Here's a hint! Some pixels have been revealed for you."
                showHint = true
            } else {
                hintMessage = "No more hints available. You're on the right track!"
                showHint = true
            }
        } else {
            hintMessage = "You've used all available hints. Try to figure out the rest!"
            showHint = true
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
    
    // Setup for adept challenge with a random 16x16 art
    func setupAdeptChallenge() {
        gridState.gridSize = 16
        gridState.cellSize = 26 // Increase cell size for better visibility and touch targets
        gridState.reset()
        
        // Load a random 16x16 art
        adeptState.loadRandomArt()
        
        // Initialize progress calculation
        calculateAdeptProgress()
    }
}
