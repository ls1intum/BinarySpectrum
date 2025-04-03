import Foundation
import SwiftUICore

@Observable class PixelGameViewModel: ObservableObject {
    var blackCells: Set<Int> = [] // Stores the black squares
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
    var progress: Double = 0.0
    
    private let gridSize = 8
    private var correctCells: Set<Int> = [] // Stores the correct black cells (based on the binary code)
    
    init() {
        generateCorrectCells()
    }
    
    private func generateCorrectCells() {
        // Generate correct cells from the binary code (1 = black, 0 = white)
        let rows = codeToDecrypt.split(separator: "\n")
        for (rowIndex, row) in rows.enumerated() {
            for (colIndex, char) in row.enumerated() {
                if char == "1" {
                    correctCells.insert(rowIndex * gridSize + colIndex)
                }
            }
        }
    }
    
    func toggleCell(_ index: Int) {
        if blackCells.contains(index) {
            blackCells.remove(index)
        } else {
            blackCells.insert(index)
        }
        
        // Update progress based on how many cells are correctly filled
        updateProgress()
    }
    
    private func updateProgress() {
        let correctFilledCells = blackCells.intersection(correctCells).count
        let totalCells = correctCells.count
        progress = totalCells > 0 ? Double(correctFilledCells) / Double(totalCells) : 0.0
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

