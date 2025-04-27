import SwiftUI

// MARK: - Views

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background and content
            VStack {
                // Top spacing to accommodate the TopBarView
                Spacer().frame(height: 60)
                
                Spacer()
                
                VStack(spacing: 24) {
                    // Reset Progress Button
                    SettingsButton(
                        title: "Reset Progress",
                        icon: "arrow.counterclockwise",
                        color: .gameRed,
                        action: {
                            showResetConfirmation = true
                        }
                    )
                    
                    // Sound Settings Button (placeholder)
                    SettingsButton(
                        title: "Sound Settings",
                        icon: "speaker.wave.3",
                        color: .gameBlue,
                        action: {
                            // Placeholder for future functionality
                        }
                    )
                    
                    // Display Settings Button (placeholder)
                    SettingsButton(
                        title: "Display Settings",
                        icon: "display",
                        color: .gameOrange,
                        action: {
                            // Placeholder for future functionality
                        }
                    )
                    
                    // About Button (placeholder)
                    SettingsButton(
                        title: "About",
                        icon: "info.circle",
                        color: .gameGreen,
                        action: {
                            // Placeholder for future functionality
                        }
                    )
                }
                .padding()
                
                Spacer()
            }
            
            // TopBarView overlay at the top
            TopBar(title: "Settings", color: .gamePurple)
            
            // Reset Confirmation Popup
            if showResetConfirmation {
                TwoButtonInfoPopup(
                    title: "Reset Progress",
                    message: "Are you sure you want to reset all game progress? This will return all mini-games to their initial state as if you're playing them for the first time. This action cannot be undone.",
                    primaryButtonTitle: "Reset",
                    secondaryButtonTitle: "Cancel",
                    onPrimaryButtonTap: {
                        userViewModel.resetProgress()
                        showResetConfirmation = false
                        showResetSuccess = true
                    },
                    onSecondaryButtonTap: {
                        showResetConfirmation = false
                    }
                )
            }
            
            // Reset Success Popup
            if showResetSuccess {
                InfoPopup(
                    title: "Progress Reset",
                    message: "All game progress has been successfully reset. The mini-games are now ready to be played from the beginning.",
                    buttonTitle: "OK",
                    onButtonTap: {
                        showResetSuccess = false
                    }
                )
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 8)
                
                Text(title)
                    .font(GameTheme.bodyFont)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .shadow(color: color.opacity(0.5), radius: 5, x: 2, y: 2)
            )
            .frame(maxWidth: 350)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NavigationState())
}
