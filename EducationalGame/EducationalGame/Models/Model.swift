import SwiftUI

struct Game: Identifiable {
    let id = UUID()
    var name: String
    var highScore: Int
    var miniGames: [MiniGame]
}

struct MiniGame: Identifiable {
    let id: Int
    let name: LocalizedStringResource
    let icon: String
    let color: Color
    let personaImage: String
    let achievementName: LocalizedStringResource
    let view: AnyView
    var highScore: Int
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

    mutating func next() {
        let allCases = GamePhase.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        self = allCases[(currentIndex + 1) % allCases.count]
    }

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
            case .noviceChallenge: self = .tutorialDialogue
            case .tutorialDialogue: self = .apprenticeChallenge
            case .apprenticeChallenge: self = .adeptChallenge
            case .adeptChallenge: self = .expertChallenge
            case .lastDialogue: self = .lastDialogue // change?
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

// Represents a grid-based image using boolean values (true = filled pixel)
struct GridImage {
    var size: Int
    var grid: [[Bool]]

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

struct PixelArt: Identifiable {
    var id = UUID()
    var name: String = "Untitled"
    var grid: GridImage

    init(name: String = "Untitled", grid: GridImage) {
        self.name = name
        self.grid = grid
    }
}
