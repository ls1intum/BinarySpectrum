enum ExperienceLevel: String, Codable {
    case novice
    case advanced
}

enum GamePhase : CaseIterable {
    case intro
    case questions
    case challenges
    case reward
    
    mutating func next() {
        let allCases = GamePhase.allCases
        let currentIndex = allCases.firstIndex(of: self)!
        self = allCases[(currentIndex + 1) % allCases.count]
    }
}

struct UserProgressModel: Codable {
    var completedMiniGames: [String: Bool]
    var totalScore: Int
    var achievements: [String]
    var experienceLevel: ExperienceLevel
    
    mutating func completeGame(_ gameName: String, score: Int) {
        completedMiniGames[gameName] = true
        totalScore += score
        achievements.append("Completed \(gameName)!")
    }
}
