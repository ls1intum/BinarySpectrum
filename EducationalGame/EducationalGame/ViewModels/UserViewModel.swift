// centralized state manager for user-related date
// provides global access to user progress, experience level, and preferences

import SwiftUI

class UserViewModel: ObservableObject {
    @Published var userProgress: UserProgressModel

    init() {
        // Load progress from storage or start fresh
        self.userProgress = UserProgressModel(
            completedMiniGames: [:],
            totalScore: 0,
            achievements: [],
            experienceLevel: .novice
        )
    }

    func completeMiniGame(_ gameName: String, score: Int) {
        userProgress.completeGame(gameName, score: score)
        // userProgress.updateExperienceLevel()
        saveProgress()
    }

    private func saveProgress() {
        // Save to UserDefaults or SwiftData
    }
}
