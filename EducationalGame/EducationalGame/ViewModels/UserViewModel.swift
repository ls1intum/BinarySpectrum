// centralized state manager for user-related data
// provides global access to user progress and achievements

import SwiftUI

// Extension to help with color persistence
extension Color {
    // Convert Color to a string representation
    var storageString: String {
        switch self {
        case .gamePurple: return "gamePurple"
        case .gameBlue: return "gameBlue"
        case .gameOrange: return "gameOrange" 
        case .gameYellow: return "gameYellow"
        case .gameGreen: return "gameGreen"
        case .gamePink: return "gamePink"
        case .gameRed: return "gameRed"
        default: return "gamePurple" // Default case
        }
    }
    
    // Create Color from string
    init(fromStorage string: String) {
        switch string {
        case "gamePurple": self = .gamePurple
        case "gameBlue": self = .gameBlue
        case "gameOrange": self = .gameOrange
        case "gameYellow": self = .gameYellow
        case "gameGreen": self = .gameGreen
        case "gamePink": self = .gamePink
        case "gameRed": self = .gameRed
        default: self = .gamePurple
        }
    }
}

class UserViewModel: ObservableObject {
    // User personal information
    @Published var userName: String = ""
    @Published var userAge: String = ""
    @Published var favoriteColor: Color = .gamePurple
    
    // Track completion status for each mini game
    @Published var completedMiniGames: [String: Bool] = [:]
    
    // Track score data for each mini game
    @Published var miniGameScores: [String: Int] = [:]
    
    // Track percentage of correct answers for each mini game
    @Published var miniGamePercentages: [String: Double] = [:]
    
    // Track achievements earned
    @Published var achievements: [String] = []
    
    // Keys for persistence
    private let userNameKey = "userName"
    private let userAgeKey = "userAge"
    private let favoriteColorKey = "favoriteColor"
    private let completedGamesKey = "completedGames"
    private let miniGameScoresKey = "miniGameScores"
    private let miniGamePercentagesKey = "miniGamePercentages"
    private let achievementsKey = "achievements"
    private let hasLaunchedBeforeKey = "hasLaunchedBefore"
    
    // Keys that might be used by other parts of the app
    private let gamePhaseKeys = [
        "BinaryGamePhase",
        "PixelGamePhase",
        "ColorGamePhase",
        "currentGamePhases"
    ]
    
    init() {
        // Initialize with empty data
        loadSavedData()
    }
    
    // Check if this is the first launch
    func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey)
    }
    
    // Set first launch completed
    func setFirstLaunchCompleted() {
        UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
    }
    
    // Save user information
    func saveUserInfo(name: String, age: String, favoriteColor: Color = .gamePurple) {
        userName = name
        userAge = age
        self.favoriteColor = favoriteColor
        saveData()
    }
    
    // Record completion of a mini game
    func completeMiniGame(_ gameName: String, score: Int, percentage: Double) {
        completedMiniGames[gameName] = true
        miniGameScores[gameName] = score
        miniGamePercentages[gameName] = percentage
        
        // Add achievement if this is the first time completing the game
        if !achievements.contains("Completed \(gameName)") {
            achievements.append("Completed \(gameName)")
        }
        
        saveData()
    }
    
    // Check if a mini game has been completed
    func isGameCompleted(_ gameName: String) -> Bool {
        return completedMiniGames[gameName] ?? false
    }
    
    // Get the score for a mini game
    func getScore(for gameName: String) -> Int {
        return miniGameScores[gameName] ?? 0
    }
    
    // Get the percentage for a mini game
    func getPercentage(for gameName: String) -> Double {
        return miniGamePercentages[gameName] ?? 0.0
    }
    
    // Reset all progress data
    func resetProgress() {
        // Clear all game progress data
        completedMiniGames = [:]
        miniGameScores = [:]
        miniGamePercentages = [:]
        achievements = []
        
        // Save changes to UserDefaults
        saveData()
        
        // Clear any other game state data that might be stored in UserDefaults
        resetAllGameStates()
        
        // Force refresh any game view models that might be in memory
        NotificationCenter.default.post(name: NSNotification.Name("ResetGameProgress"), object: nil)
    }
    
    // MARK: - Private Methods
    
    private func saveData() {
        let defaults = UserDefaults.standard
        
        // Save user information
        defaults.set(userName, forKey: userNameKey)
        defaults.set(userAge, forKey: userAgeKey)
        defaults.set(favoriteColor.storageString, forKey: favoriteColorKey)
        
        // Save completed games
        if let encoded = try? JSONEncoder().encode(completedMiniGames) {
            defaults.set(encoded, forKey: completedGamesKey)
        }
        
        // Save scores
        if let encoded = try? JSONEncoder().encode(miniGameScores) {
            defaults.set(encoded, forKey: miniGameScoresKey)
        }
        
        // Save percentages
        if let encoded = try? JSONEncoder().encode(miniGamePercentages) {
            defaults.set(encoded, forKey: miniGamePercentagesKey)
        }
        
        // Save achievements
        if let encoded = try? JSONEncoder().encode(achievements) {
            defaults.set(encoded, forKey: achievementsKey)
        }
        
        // Notify listeners that user data has been updated
        NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
    }
    
    private func loadSavedData() {
        let defaults = UserDefaults.standard
        
        // Load user information
        userName = defaults.string(forKey: userNameKey) ?? ""
        userAge = defaults.string(forKey: userAgeKey) ?? ""
        favoriteColor = Color(fromStorage: defaults.string(forKey: favoriteColorKey) ?? "gamePurple")
        
        // Load completed games
        if let savedData = defaults.data(forKey: completedGamesKey),
           let decoded = try? JSONDecoder().decode([String: Bool].self, from: savedData) {
            completedMiniGames = decoded
        }
        
        // Load scores
        if let savedData = defaults.data(forKey: miniGameScoresKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: savedData) {
            miniGameScores = decoded
        }
        
        // Load percentages
        if let savedData = defaults.data(forKey: miniGamePercentagesKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: savedData) {
            miniGamePercentages = decoded
        }
        
        // Load achievements
        if let savedData = defaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: savedData) {
            achievements = decoded
        }
    }
    
    private func resetAllGameStates() {
        let defaults = UserDefaults.standard
        
        // Remove known game phase keys
        for key in gamePhaseKeys {
            defaults.removeObject(forKey: key)
        }
        
        // Also remove any keys that might be related to game progress
        let allKeys = defaults.dictionaryRepresentation().keys
        let progressKeys = allKeys.filter { key in
            return key.contains("Game") && 
                  (key.contains("Phase") || 
                   key.contains("Progress") || 
                   key.contains("State") ||
                   key.contains("Completed"))
        }
        
        for key in progressKeys {
            defaults.removeObject(forKey: key)
        }
        
        // Ensure specific game phases are reset
        defaults.removeObject(forKey: "BinaryGameCurrentPhase")
        defaults.removeObject(forKey: "PixelGameCurrentPhase")
        defaults.removeObject(forKey: "ColorGameCurrentPhase")
        
        // Synchronize to ensure changes are saved
        defaults.synchronize()
    }
}
