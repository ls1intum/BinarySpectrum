import Foundation
import SwiftUICore

// MARK: - Constants
let LocalizeUserDefaultKey = "LocalizeUserDefaultKey"

// MARK: - Localization Manager (Model)
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    // Published to trigger UI updates when language changes
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.setValue(currentLanguage, forKey: LocalizeUserDefaultKey)
            updateBundle()
            NotificationCenter.default.post(name: Notification.Name("LanguageDidChange"), object: nil)
        }
    }
    
    private var bundle: Bundle?
    
    private init() {
        // Initialize with stored language or default
        currentLanguage = UserDefaults.standard.string(forKey: LocalizeUserDefaultKey) ?? "en"
        updateBundle()
    }
    
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let newBundle = Bundle(path: path) {
            bundle = newBundle
        } else {
            bundle = Bundle.main
        }
    }
    
    func localizedString(for key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: "Localizable") ?? key
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}

// MARK: - Language Model
struct LanguageOption: Identifiable {
    let id = UUID()
    let code: String
    let emoji: String
    let color: Color
}
