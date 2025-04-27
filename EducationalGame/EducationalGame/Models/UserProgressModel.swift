import Foundation
import SwiftUI

enum ExperienceLevel: String, Codable {
    case novice
    case advanced
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
