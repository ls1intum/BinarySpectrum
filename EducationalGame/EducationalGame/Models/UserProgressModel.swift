enum ExperienceLevel: String, Codable {
    case novice
    case advanced
}

enum GamePhase: String, CaseIterable {
    case intro = "Introduction"
    case questions = "Questions"
    case exploration = "Exploration"
    case tutorial = "Tutorial"
    case practice = "Practice"
    case challenges = "Challenges"
    case advancedChallenges = "Advanced Challenges"
    case finalChallenge = "Final Challenge"
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
            case .intro: self = .questions
            case .questions: self = .tutorial
            case .tutorial: self = .practice
            case .practice: self = .challenges
            case .challenges: self = .advancedChallenges
            case .advancedChallenges: self = .finalChallenge
            case .finalChallenge: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        case "Pixel Art Game":
            switch self {
            case .intro: self = .exploration
            case .exploration: self = .tutorial
            case .tutorial: self = .practice
            case .practice: self = .challenges
            case .challenges: self = .advancedChallenges
            case .advancedChallenges: self = .finalChallenge
            case .finalChallenge: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        case "Color Game":
            switch self {
            case .intro: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .tutorial
            case .tutorial: self = .challenges
            case .challenges: self = .finalChallenge
            case .finalChallenge: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        default:
            self = .intro
        }
    }
    
    // Helper function to check if a phase is valid for a specific game
    func isValid(for gameType: String) -> Bool {
        switch gameType {
        case "Binary Game":
            return [.intro, .questions, .tutorial, .practice, .challenges, .advancedChallenges, .finalChallenge, .reward].contains(self)
        case "Pixel Art Game":
            return [.intro, .exploration, .tutorial, .practice, .challenges, .advancedChallenges, .finalChallenge, .reward].contains(self)
        case "Color Game":
            return [.intro, .questions, .exploration, .tutorial, .challenges, .finalChallenge, .reward].contains(self)
        default:
            return false
        }
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
