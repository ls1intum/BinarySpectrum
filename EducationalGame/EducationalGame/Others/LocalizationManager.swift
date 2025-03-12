import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()

    func setLanguage(_ language: String) {
        UserDefaults.standard.setValue(language, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }

    func getLanguage() -> String {
        return UserDefaults.standard.string(forKey: "selectedLanguage") ?? "EN"
    }
}
