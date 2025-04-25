import Foundation
import SwiftUI

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
            case .questions: self = .exploration
            case .exploration: self = .tutorial
            case .tutorial: self = .practice
            case .practice: self = .challenges
            case .challenges: self = .advancedChallenges
            case .advancedChallenges: self = .finalChallenge
            case .finalChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        case "Pixel Art Game":
            switch self {
            case .intro: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .practice
            case .practice: self = .tutorial
            case .tutorial: self = .challenges
            case .challenges: self = .advancedChallenges
            case .advancedChallenges: self = .finalChallenge
            case .finalChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        case "Color Game":
            switch self {
            case .intro: self = .questions
            case .questions: self = .exploration
            case .exploration: self = .tutorial
            case .tutorial: self = .practice
            case .practice: self = .challenges
            case .challenges: self = .advancedChallenges
            case .advancedChallenges: self = .finalChallenge
            case .finalChallenge: self = .review
            case .review: self = .reward
            case .reward: self = .intro
            default: self = .intro
            }
        default:
            self = .intro
        }
    }
}

// Use only ObservableObject for better compatibility with SwiftUI views
class UserProgressModel: ObservableObject {
    @Published var completedMiniGames: [String: Bool]
    @Published var totalScore: Int
    @Published var achievements: [String]
    @Published var experienceLevel: ExperienceLevel
    @Published var currentGamePhase: [String: GamePhase] = [:]
    
    init() {
        self.completedMiniGames = [:]
        self.totalScore = 0
        self.achievements = []
        self.experienceLevel = .novice
        
        // Initialize default phases for each game
        self.currentGamePhase = [
            "Binary Game": .intro,
            "Pixel Art Game": .intro,
            "Color Game": .intro
        ]
    }
    
    func completeGame(_ gameName: String, score: Int) {
        completedMiniGames[gameName] = true
        totalScore += score
        achievements.append("Completed \(gameName)!")
        
        // Update experience level based on score
        updateExperienceLevel()
    }
    
    func updateExperienceLevel() {
        // Logic to update experience level based on total score
        if totalScore >= 500 {
            experienceLevel = .advanced
        } else {
            experienceLevel = .novice
        }
    }
    
    func getPhase(for gameType: String) -> GamePhase {
        return currentGamePhase[gameType] ?? .intro
    }
    
    func setPhase(_ phase: GamePhase, for gameType: String) {
        currentGamePhase[gameType] = phase
    }
    
    func advancePhase(for gameType: String) {
        guard var currentPhase = currentGamePhase[gameType] else {
            currentGamePhase[gameType] = .intro
            return
        }
        currentPhase.next()
        currentGamePhase[gameType] = currentPhase
    }
}
