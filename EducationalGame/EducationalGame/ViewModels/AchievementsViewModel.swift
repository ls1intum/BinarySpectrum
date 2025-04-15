import Foundation

@Observable class AchievementsViewModel {
    // Achievement states for each mini game
    var binaryAchievement: Bool = false
    var pixelAchievement: Bool = false
    var colorAchievement: Bool = false
    
    // Achievement titles and descriptions
    let achievements: [(id: Int, title: String, description: String)] = [
        (0, "Binary Master", "Complete the Binary Numbers game"),
        (1, "Pixel Master", "Complete the Pixel Decoder game"),
        (2, "Color Master", "Complete the Color Game")
    ]
    
    // Check if an achievement is unlocked
    func isAchievementUnlocked(forGameId id: Int) -> Bool {
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

