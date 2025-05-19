import SwiftUI

private struct CurrentViewKey: EnvironmentKey {
    static let defaultValue: String = ""
}

private struct CurrentPhaseKey: EnvironmentKey {
    static let defaultValue: GamePhase = .introDialogue
}

extension EnvironmentValues {
    var currentView: String {
        get { self[CurrentViewKey.self] }
        set { self[CurrentViewKey.self] = newValue }
    }

    var currentPhase: GamePhase {
        get { self[CurrentPhaseKey.self] }
        set { self[CurrentPhaseKey.self] = newValue }
    }
}
