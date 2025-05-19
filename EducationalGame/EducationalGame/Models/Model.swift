import SwiftUI

struct Game: Identifiable {
    let id = UUID()
    var name: String
    var miniGames: [MiniGame]
}

struct MiniGame: Identifiable {
    let id: Int
    let name: LocalizedStringResource
    let icon: String
    let color: Color
    let personaName: String
    let personaImage: String
    let achievementName: LocalizedStringResource
    let view: AnyView
}

struct Challenge: Identifiable {
    let id: Int
    let name: LocalizedStringResource
    let icon: String
    let miniGameId: Int
    let phase: GamePhase
}

struct Question: Identifiable {
    let id = UUID()
    let question: LocalizedStringResource
    let alternatives: [Int: LocalizedStringResource]
    let correctAnswer: Int
    let explanation: LocalizedStringResource
}

struct ReviewCard: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let content: LocalizedStringResource
    let example: LocalizedStringResource
}

struct ReviewItem: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let content: LocalizedStringResource
    let example: LocalizedStringResource
}

enum GamePhase: String, CaseIterable, Codable {
    case introDialogue = "Introduction Dialogue"
    case questions = "Questions"
    case exploration = "Exploration"
    case tutorialDialogue = "Tutorial Dialogue"
    case lastDialogue = "Last Dialogue"
    case noviceChallenge = "Novice Challenge"
    case apprenticeChallenge = "Apprentice Challenge"
    case adeptChallenge = "Adept Challenge"
    case expertChallenge = "Expert Challenge"
    case review = "Review"
    case reward = "Reward"

    // Helper function to get the next phase based on game type
    mutating func next(for gameType: String) {
        switch gameType {
        case "Binary Game":
            switch self {
            case .introDialogue: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .tutorialDialogue
            case .tutorialDialogue: self = .noviceChallenge
            case .noviceChallenge: self = .apprenticeChallenge
            case .apprenticeChallenge: self = .adeptChallenge
            case .adeptChallenge: self = .lastDialogue
            case .lastDialogue: self = .expertChallenge
            case .expertChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .introDialogue
            }
        case "Pixel Game":
            switch self {
            case .introDialogue: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .noviceChallenge
            case .noviceChallenge: self = .apprenticeChallenge
            case .apprenticeChallenge: self = .tutorialDialogue
            case .tutorialDialogue: self = .adeptChallenge
            case .adeptChallenge: self = .lastDialogue
            case .lastDialogue: self = .expertChallenge
            case .expertChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .introDialogue
            }
        case "Color Game":
            switch self {
            case .introDialogue: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .tutorialDialogue
            case .tutorialDialogue: self = .noviceChallenge
            case .noviceChallenge: self = .lastDialogue
            case .lastDialogue: self = .apprenticeChallenge
            case .apprenticeChallenge: self = .adeptChallenge
            case .adeptChallenge: self = .expertChallenge
            case .expertChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .introDialogue
            }
        default:
            self = .introDialogue
        }
    }
}

struct PixelArt: Identifiable {
    var id = UUID()
    var name: String = "Untitled"
    var grid: GridImage

    init(name: String = "Untitled", grid: GridImage) {
        self.name = name
        self.grid = grid
    }
}

// Represents a grid-based image using boolean values (true = filled pixel)
struct GridImage {
    var size: Int
    var grid: [[Bool]]

    // Computed property that returns all black pixel indices as a Set
    var blackPixels: Set<Int> {
        var pixels = Set<Int>()
        for row in 0..<size {
            for column in 0..<size {
                if grid[row][column] {
                    pixels.insert(index(from: (row, column)))
                }
            }
        }
        return pixels
    }

    init(size: Int = 8, blackPixels: Set<Int> = []) {
        self.size = size
        self.grid = Array(repeating: Array(repeating: false, count: size), count: size)

        for index in blackPixels {
            let position = self.position(from: index)
            if position.row >= 0, position.row < size,
               position.column >= 0, position.column < size
            {
                grid[position.row][position.column] = true
            }
        }
    }

    // Overload initializer to accept an array of Int
    init(size: Int = 8, blackPixels: [Int]) {
        self.init(size: size, blackPixels: Set(blackPixels))
    }

    // Initialize a grid from a hexadecimal string (supports both 8x8 and 16x16)
    init(hexString: String) {
        let cleanHex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Determine grid size based on hex string length (16 chars for 8x8, 64 chars for 16x16)
        if cleanHex.count == 16 {
            self.size = 8
            self.grid = Array(repeating: Array(repeating: false, count: 8), count: 8)
        } else {
            self.size = 16
            self.grid = Array(repeating: Array(repeating: false, count: 16), count: 16)
        }

        // Verify it's a valid hex string
        guard let regex = try? NSRegularExpression(pattern: "^[0-9A-Fa-f]+$"),
              cleanHex.count == 16 || cleanHex.count == 64
        else {
            return
        }

        let range = NSRange(location: 0, length: cleanHex.utf16.count)
        guard regex.firstMatch(in: cleanHex, options: [], range: range) != nil else {
            return
        }

        // Process each hex digit (4 bits each)
        for (index, char) in cleanHex.enumerated() {
            // Convert hex digit to binary (0-15)
            let hexValue = Int(String(char), radix: 16)!

            // Each hex digit represents 4 cells in the grid
            // Calculate starting position for this hex digit
            let startingIndex = index * 4
            let startRow = (startingIndex / size)
            let startCol = (startingIndex % size)

            // Convert the hex digit (0-15) to 4 binary bits
            // e.g. 9 (hex) = 1001 (binary)
            let bit3 = (hexValue & 0b1000) > 0
            let bit2 = (hexValue & 0b0100) > 0
            let bit1 = (hexValue & 0b0010) > 0
            let bit0 = (hexValue & 0b0001) > 0

            // Position the 4 bits in the correct grid cells
            if startRow < size, startCol < size {
                grid[startRow][startCol] = bit3
            }
            if startRow < size, startCol + 1 < size {
                grid[startRow][startCol + 1] = bit2
            }
            if startRow < size, startCol + 2 < size {
                grid[startRow][startCol + 2] = bit1
            }
            if startRow < size, startCol + 3 < size {
                grid[startRow][startCol + 3] = bit0
            }
        }
    }

    // Convert grid to a hexadecimal string
    func toHexString() -> String {
        var hexString = ""

        for row in 0..<size {
            for col in stride(from: 0, to: size, by: 4) {
                // Convert 4 adjacent bits to a hex digit
                var value = 0
                if col < size && grid[row][col] {
                    value |= 0b1000
                }
                if col + 1 < size && grid[row][col + 1] {
                    value |= 0b0100
                }
                if col + 2 < size && grid[row][col + 2] {
                    value |= 0b0010
                }
                if col + 3 < size && grid[row][col + 3] {
                    value |= 0b0001
                }

                // Convert value (0-15) to hex digit
                let hexDigit = String(value, radix: 16)
                hexString += hexDigit
            }
        }

        return hexString
    }

    // Converts a linear index to a row and column position
    func position(from index: Int) -> (row: Int, column: Int) {
        let row = index / size
        let column = index % size
        return (row, column)
    }

    // Converts a row and column position to a linear index
    func index(from position: (row: Int, column: Int)) -> Int {
        position.row * size + position.column
    }

    // Checks if the position is within the grid bounds
    func isValidPosition(_ row: Int, _ column: Int) -> Bool {
        row >= 0 && row < size && column >= 0 && column < size
    }

    // Gets the value at a specific position, returning false if out of bounds
    func valueAt(row: Int, column: Int) -> Bool {
        guard isValidPosition(row, column) else { return false }
        return grid[row][column]
    }

    // Sets the value at a specific position if it's within bounds
    mutating func setValue(_ value: Bool, at row: Int, column: Int) {
        guard isValidPosition(row, column) else { return }
        grid[row][column] = value
    }
}
