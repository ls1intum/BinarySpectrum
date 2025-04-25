import Foundation

@Observable class AchievementsViewModel {
    // Achievement states for each mini game
    var binaryAchievement: Bool = false
    var pixelAchievement: Bool = false
    var colorAchievement: Bool = false
    
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
        // Check for achievements in the shared user view model
        binaryAchievement = checkCompletionForGame(name: "Binary Game")
        pixelAchievement = checkCompletionForGame(name: "Pixel Game")
        colorAchievement = checkCompletionForGame(name: "Color Game")
    }
    
    private func checkCompletionForGame(name: String) -> Bool {
        // Check if any game phase with this base name has been completed
        // Either the base game or specific phases like "Binary Game - reward"
        let matchingAchievements = sharedUserViewModel.achievements.filter { 
            $0.contains(name)
        }
        
        // Check completions directly from completedMiniGames
        let completedGames = sharedUserViewModel.completedMiniGames.filter { 
            $0.key.contains(name) && $0.value == true
        }
        
        // Return true if there's any matching achievement or completed game
        return !matchingAchievements.isEmpty || !completedGames.isEmpty
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

