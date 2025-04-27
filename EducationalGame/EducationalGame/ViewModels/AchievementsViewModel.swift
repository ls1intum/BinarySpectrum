import Foundation
import SwiftUI

class AchievementsViewModel: ObservableObject {
    // Achievement states for each mini game
    @Published var binaryAchievement: Bool = false
    @Published var pixelAchievement: Bool = false
    @Published var colorAchievement: Bool = false
    
    // UserDefaults keys
    private let completedMiniGamesKey = "completedMiniGames"
    private let achievementsKey = "achievements"
    
    // Achievement titles and descriptions
    let achievements: [(id: Int, title: String, description: String)] = [
        (0, "Binary Master", "Complete the Binary Game"),
        (1, "Pixel Master", "Complete the Pixel Game"),
        (2, "Color Master", "Complete the Color Game")
    ]
    
    init() {
        updateAchievementsFromUserViewModel()
        
        // Listen for updates to user data
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAchievementsFromUserViewModel),
            name: NSNotification.Name("UserDataUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateAchievementsFromUserViewModel() {
        // Get the user data from UserDefaults
        let completedGames = getCompletedGames()
        let userAchievements = getAchievements()
        
        // Print debug information
        print("Completed games: \(completedGames)")
        print("User achievements: \(userAchievements)")
        
        // Check for achievements
        binaryAchievement = checkCompletionForGame(name: "Binary Game", completedGames: completedGames, achievements: userAchievements)
        pixelAchievement = checkCompletionForGame(name: "Pixel Game", completedGames: completedGames, achievements: userAchievements)
        colorAchievement = checkCompletionForGame(name: "Color Game", completedGames: completedGames, achievements: userAchievements)
        
        // Print achievement states
        print("Binary achievement: \(binaryAchievement)")
        print("Pixel achievement: \(pixelAchievement)")
        print("Color achievement: \(colorAchievement)")
    }
    
    private func getCompletedGames() -> [String: Bool] {
        if let data = UserDefaults.standard.data(forKey: completedMiniGamesKey),
           let decodedGames = try? JSONDecoder().decode([String: Bool].self, from: data) {
            return decodedGames
        }
        return [:]
    }
    
    private func getAchievements() -> [String] {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decodedAchievements = try? JSONDecoder().decode([String].self, from: data) {
            return decodedAchievements
        }
        return []
    }
    
    private func checkCompletionForGame(name: String, completedGames: [String: Bool], achievements: [String]) -> Bool {
        // Check if any game phase with this base name has been completed
        // Either the base game or specific phases like "Binary Game - reward"
        let matchingAchievements = achievements.filter { 
            $0.contains(name)
        }
        
        // Check completions directly from completedMiniGames
        let completedGameEntries = completedGames.filter { 
            $0.key.contains(name) && $0.value == true
        }
        
        // Return true if there's any matching achievement or completed game
        return !matchingAchievements.isEmpty || !completedGameEntries.isEmpty
    }
    
    // Check if an achievement is unlocked
    func isAchievementUnlocked(forGameId id: Int) -> Bool {
        // Update from user view model before checking
        updateAchievementsFromUserViewModel()
        
        switch id {
        case 0: return binaryAchievement
        case 1: return pixelAchievement
        case 2: return colorAchievement
        default: return false
        }
    }
    
    // Unlock an achievement
    func unlockAchievement(forGameId id: Int) {
        switch id {
        case 0: binaryAchievement = true
        case 1: pixelAchievement = true
        case 2: colorAchievement = true
        default: break
        }
    }
}

