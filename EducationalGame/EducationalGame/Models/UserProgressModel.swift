enum ExperienceLevel: String, Codable {
    case novice
    case advanced
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
