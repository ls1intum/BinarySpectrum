import SwiftUI

struct LocalizationObserver: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    func body(content: Content) -> some View {
        content
            .id(localizationManager.currentLanguage) // Force view refresh on language change
    }
}

extension View {
    func localizable() -> some View {
        modifier(LocalizationObserver())
    }
}

// MARK: - Views
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            TopBarView(title: "Settings", color: .gray)
            
            Spacer()
            
            HStack(spacing: 40) {
                ForEach(viewModel.languages) { language in
                    LanguageButtonView(
                        language: language,
                        isSelected: viewModel.isSelected(language.code),
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                viewModel.setLanguage(language.code)
                            }
                        }
                    )
                }
            }
            .padding()
            Spacer()
        }
        .localizable() // Apply the view modifier to refresh the entire view
    }
}

struct LanguageButtonView: View {
    let language: LanguageOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? language.color : language.color.opacity(0.5))
                    .frame(width: 120, height: 120)
                    .shadow(color: language.color.opacity(0.6), radius: 8, x: 4, y: 4)
                
                Text(language.emoji)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
        }
    }
}
#Preview {
    SettingsView()
}
