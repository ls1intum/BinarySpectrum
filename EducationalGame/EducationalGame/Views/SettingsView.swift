import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "EN"

    var body: some View {
        TopBarView(title: "Settings", color: .gray)
        HStack(spacing: 40) {
            LanguageButtonView(language: "EN", emoji: "🇺🇸", color: .gameBlue, selectedLanguage: $selectedLanguage)
            LanguageButtonView(language: "DE", emoji: "🇩🇪", color: .gameYellow, selectedLanguage: $selectedLanguage)
            LanguageButtonView(language: "PT-BR", emoji: "🇧🇷", color: .gameGreen, selectedLanguage: $selectedLanguage)
        }
        .onAppear {
            updateLanguage()
        }
    }

    func updateLanguage() {
        LocalizationManager.shared.setLanguage(selectedLanguage)
    }
}

struct LanguageButtonView: View {
    var language: String
    var emoji: String
    var color: Color
    @Binding var selectedLanguage: String

    var body: some View {
        ZStack {
            Circle()
                .fill(selectedLanguage == language ? color : color.opacity(0.5))
                .frame(width: 120, height: 120)
                .shadow(color: color.opacity(0.6), radius: 8, x: 4, y: 4)

            Text(emoji)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(selectedLanguage == language ? 1.2 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                selectedLanguage = language
                LocalizationManager.shared.setLanguage(language)
            }
        }
    }
}

#Preview {
    SettingsView()
}
