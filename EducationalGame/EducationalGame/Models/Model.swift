import SwiftUICore

struct Game {
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
    let achievementName: String
    let view: AnyView
    var highScore: Int
}

struct Question {
    let question: String
    let alternatives: [Int: String]
    let correctAnswer: Int
    let explanation: String
}

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

    /// Converts a linear index to a row and column position
    func position(from index: Int) -> (row: Int, column: Int) {
        let row = index / size
        let column = index % size
        return (row, column)
    }

    /// Converts a row and column position to a linear index
    func index(from position: (row: Int, column: Int)) -> Int {
        return position.row * size + position.column
    }
}

struct PixelArt {
    var id = UUID()
    var name: String = "Untitled"
    var grid: GridImage

    init(name: String = "Untitled", grid: GridImage) {
        self.name = name
        self.grid = grid
    }
}
