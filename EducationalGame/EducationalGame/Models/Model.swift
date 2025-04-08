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
    let personaImage: Image
    let view: AnyView
    // let questions: [Question]
    var highScore: Int
}

struct Question {
    let question: String
    let alternatives: [Int: String]
    let correctAnswer: Int
    let explanation: String
}
