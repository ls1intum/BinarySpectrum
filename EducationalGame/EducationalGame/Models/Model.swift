struct Game {
    var name: String
    var highScore: Int
    var miniGames: [MiniGame]
}

struct MiniGame {
    let id: Int
    let name: String
    //let questions: [Question]
    var highScore: Int
}

struct Question {
    let question: String
    let alternatives: [Int: String]
    let correctAnswer: Int
}
