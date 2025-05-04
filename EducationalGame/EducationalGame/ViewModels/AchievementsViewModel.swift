import Foundation
import SwiftUI

class AchievementsViewModel: ObservableObject {
    // Achievement states for each mini game
    @Published var binaryAchievement: Bool = false
    @Published var pixelAchievement: Bool = false
    @Published var colorAchievement: Bool = false
    
    // Reference to shared UserViewModel
    private let userViewModel = sharedUserViewModel
    
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
        
        // Listen for game progress reset
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAchievementsFromUserViewModel),
            name: NSNotification.Name("ResetGameProgress"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateAchievementsFromUserViewModel() {
        print("Updating achievements from UserViewModel")
        print("Current UserViewModel achievements: \(userViewModel.achievements)")
        print("Current UserViewModel completed games: \(userViewModel.completedMiniGames)")
        
        // Reset all achievement states first
        binaryAchievement = false
        pixelAchievement = false
        colorAchievement = false
        
        // Check for achievements based on userViewModel data
        binaryAchievement = checkCompletionForGame(name: "Binary Game")
        pixelAchievement = checkCompletionForGame(name: "Pixel Game")
        colorAchievement = checkCompletionForGame(name: "Color Game")
        
        // Print achievement states
        print("Binary achievement: \(binaryAchievement)")
        print("Pixel achievement: \(pixelAchievement)")
        print("Color achievement: \(colorAchievement)")
    }
    
    private func checkCompletionForGame(name: String) -> Bool {
        // Check if any game phase with this base name has been completed
        let matchingAchievements = userViewModel.achievements.filter { 
            $0.contains(name)
        }
        
        // Check completions directly from completedMiniGames
        let completedGameEntries = userViewModel.completedMiniGames.filter { 
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
        // First verify that the achievement is actually unlocked in UserViewModel
        updateAchievementsFromUserViewModel()
        
        // Only set the achievement if it's already unlocked through game completion
        switch id {
        case 0: 
            if checkCompletionForGame(name: "Binary Game") {
                binaryAchievement = true
            }
        case 1: 
            if checkCompletionForGame(name: "Pixel Game") {
                pixelAchievement = true
            }
        case 2: 
            if checkCompletionForGame(name: "Color Game") {
                colorAchievement = true
            }
        default: break
        }
    }
}

