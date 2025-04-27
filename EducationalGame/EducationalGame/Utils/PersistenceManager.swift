import Foundation
import SwiftUI

// Handles all persistence operations for the app using UserDefaults
@Observable final class PersistenceManager {
    // Shared instance for singleton access
    static let shared = PersistenceManager()
    
    // Storage keys for UserDefaults
    enum StorageKey: String {
        case userName
        case userAge
        case favoriteColor
        case completedGames
        case miniGameScores
        case miniGamePercentages
        case achievements
        case hasLaunchedBefore
        case binaryGamePhase
        case pixelGamePhase
        case colorGamePhase
        case currentGamePhases
        case preferences
        case soundEnabled
        case hapticEnabled
        
        // The actual key used in UserDefaults
        var key: String { rawValue }
    }
    
    private init() {}
    
    // Checks if this is the first launch of the app
    var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: StorageKey.hasLaunchedBefore.key)
    }
    
    // Sets the first launch as completed
    func setFirstLaunchCompleted() {
        UserDefaults.standard.set(true, forKey: StorageKey.hasLaunchedBefore.key)
    }
    
    // Generic method to save any Codable object
    func save<T: Encodable>(_ object: T, forKey key: StorageKey) {
        if let encoded = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(encoded, forKey: key.key)
        }
    }
    
    // Generic method to load any Codable object
    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    // Save a string value
    func saveString(_ value: String, forKey key: StorageKey) {
        UserDefaults.standard.set(value, forKey: key.key)
    }
    
    // Load a string value
    func loadString(forKey key: StorageKey) -> String {
        UserDefaults.standard.string(forKey: key.key) ?? ""
    }
    
    // Save a boolean value
    func saveBool(_ value: Bool, forKey key: StorageKey) {
        UserDefaults.standard.set(value, forKey: key.key)
    }
    
    // Load a boolean value
    func loadBool(forKey key: StorageKey) -> Bool {
        UserDefaults.standard.bool(forKey: key.key)
    }
    
    // Save a color value
    func saveColor(_ color: Color, forKey key: StorageKey) {
        UserDefaults.standard.set(color.storageString, forKey: key.key)
    }
    
    // Load a color value
    func loadColor(forKey key: StorageKey) -> Color {
        let colorString = UserDefaults.standard.string(forKey: key.key) ?? "gamePurple"
        return Color(fromStorage: colorString)
    }
    
    // Remove a specific key from UserDefaults
    func removeValue(forKey key: StorageKey) {
        UserDefaults.standard.removeObject(forKey: key.key)
    }
    
    // Remove a list of specific keys from UserDefaults
    func removeValues(forKeys keys: [StorageKey]) {
        keys.forEach { removeValue(forKey: $0) }
    }
    
    // Reset all game-related data
    func resetAllGameData() {
        let defaults = UserDefaults.standard
        
        // Remove known game phase keys
        removeValues(forKeys: [
            .binaryGamePhase,
            .pixelGamePhase,
            .colorGamePhase,
            .currentGamePhases
        ])
        
        // Find and remove any game-related keys
        let allKeys = defaults.dictionaryRepresentation().keys
        let progressKeys = allKeys.filter { key in
            key.contains("Game") &&
                (key.contains("Phase") ||
                    key.contains("Progress") ||
                    key.contains("State") ||
                    key.contains("Completed"))
        }
        
        for key in progressKeys {
            defaults.removeObject(forKey: key)
        }
    }
}
