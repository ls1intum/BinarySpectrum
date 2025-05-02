import SwiftUI

// MARK: - Views

struct SettingsView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    @State private var showProfileEdit = false
    @State private var hapticEnabled = HapticService.shared.isHapticEnabled
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
                    
                    // Haptic Feedback Toggle
                    Toggle(isOn: HapticService.supportsHaptics ? $hapticEnabled : .constant(false)) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.system(size: 24))
                                .foregroundColor(.gameWhite)
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                            
                            Text("Haptic Feedback")
                                .font(GameTheme.bodyFont)
                                .foregroundColor(.gameWhite)
                        }
                    }
                    .disabled(!HapticService.supportsHaptics)
                    .toggleStyle(SwitchToggleStyle(tint: .gameGreen))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(HapticService.supportsHaptics ? Color.gamePurple : Color.gamePurple.opacity(0.5))
                            .shadow(color: HapticService.supportsHaptics ? Color.gamePurple.opacity(0.5) : Color.gamePurple.opacity(0.2), radius: 5, x: 2, y: 2)
                    )
                    .frame(maxWidth: 350)
                    .onChange(of: hapticEnabled) { _, newValue in
                        HapticService.shared.toggleHaptic()
                        // Provide feedback when turned on
                        if newValue {
                            HapticService.shared.play(.medium)
                        }
                    }
                    
                    // Display Settings Button (placeholder)
                    SettingsButton(
                        title: "Edit Profile",
                        icon: "person",
                        color: .gameOrange,
                        action: {
                            showProfileEdit = true
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
            TopBar(title: "Settings", color: .gamePurple, infoButtonDisabled: true)

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
                        // Add haptic feedback for reset action
                        HapticService.shared.play(.heavy)
                    },
                    onSecondaryButtonTap: {
                        showResetConfirmation = false
                        // Add haptic feedback for cancel action
                        HapticService.shared.play(.light)
                    }
                )
            }

            if showResetSuccess {
                InfoPopup(
                    title: "Progress Reset",
                    message: "All game progress has been successfully reset. The mini-games are now ready to be played from the beginning.",
                    buttonTitle: "OK",
                    onButtonTap: {
                        showResetSuccess = false
                        // Add haptic feedback for OK button
                        HapticService.shared.play(.light)
                    }
                )
            }
            
            if showProfileEdit {
                ProfileEditPopup(
                    isShowing: $showProfileEdit
                )
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SettingsButton: View {
    let title: LocalizedStringResource
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Add haptic feedback before performing the action
            HapticService.shared.play(.buttonTap)
            action()
        }) {
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
