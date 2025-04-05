import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var currentLanguage: String
    
    let languages: [LanguageOption] = [
        LanguageOption(code: "en", emoji: "🇺🇸", color: .blue),
        LanguageOption(code: "de", emoji: "🇩🇪", color: .yellow),
        LanguageOption(code: "pt-BR", emoji: "🇧🇷", color: .green)
    ]
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.currentLanguage = LocalizationManager.shared.currentLanguage
        
        // Subscribe to changes in the LocalizationManager
        LocalizationManager.shared.$currentLanguage
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.currentLanguage = newValue
            }
            .store(in: &cancellables)
    }
    
    func setLanguage(_ code: String) {
        LocalizationManager.shared.setLanguage(code)
    }
    
    func isSelected(_ code: String) -> Bool {
        return currentLanguage == code
    }
}
