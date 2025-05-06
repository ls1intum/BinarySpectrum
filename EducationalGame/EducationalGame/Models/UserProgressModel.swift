import Foundation
import SwiftUI

enum ExperienceLevel: String, Codable {
    case rookie
    case pro
}

// Use only ObservableObject for better compatibility with SwiftUI views
class UserProgressModel: ObservableObject {
    @Published var completedMiniGames: [String: Bool]
    @Published var totalScore: Int
    @Published var achievements: [String]
    @Published var experienceLevel: ExperienceLevel
    @Published var currentGamePhase: [String: GamePhase] = [:]
    
    // Per-game experience level settings
    @Published var gameExperienceLevels: [String: ExperienceLevel] = [:]
    @Published var autoAdjustExperienceLevel: Bool = true
    @Published var gamePerformancePercentages: [String: Double] = [:]
    
    init() {
        self.completedMiniGames = [:]
        self.totalScore = 0
        self.achievements = []
        self.experienceLevel = .rookie
        
        // Initialize default phases for each game
        self.currentGamePhase = [
            "Binary Game": .introDialogue,
            "Pixel Art Game": .introDialogue,
            "Color Game": .introDialogue
        ]
        
        // Initialize default experience levels for each game
        self.gameExperienceLevels = [
            "Binary Game": .rookie,
            "Pixel Art Game": .rookie,
            "Color Game": .rookie
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
            experienceLevel = .pro
        } else {
            experienceLevel = .rookie
        }
    }
    
    func getPhase(for gameType: String) -> GamePhase {
        return currentGamePhase[gameType] ?? .introDialogue
    }
    
    func setPhase(_ phase: GamePhase, for gameType: String) {
        currentGamePhase[gameType] = phase
    }
    
    // Get the experience level for a specific game
    func getExperienceLevel(for gameType: String) -> ExperienceLevel {
        return gameExperienceLevels[gameType] ?? .rookie
    }
    
    // Set the experience level for a specific game
    func setExperienceLevel(_ level: ExperienceLevel, for gameType: String) {
        gameExperienceLevels[gameType] = level
    }
    
    // Update game performance and adjust experience level if needed
    func updateGamePerformance(for gameType: String, correctAnswers: Int, totalQuestions: Int) {
        let percentage = Double(correctAnswers) / Double(totalQuestions)
        gamePerformancePercentages[gameType] = percentage
        
        // Only auto-adjust if enabled
        if autoAdjustExperienceLevel {
            // If player gets 75% or more correct, set to pro level
            if percentage >= 0.75 {
                gameExperienceLevels[gameType] = .pro
            } else {
                gameExperienceLevels[gameType] = .rookie
            }
        }
    }
}
