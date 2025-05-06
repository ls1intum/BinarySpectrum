import SwiftUI

struct SettingsView: View {
    @StateObject private var userViewModel = sharedUserViewModel
    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    @State private var showProfileEdit = false
    @State private var showSoundSettings = false
    @State private var showDifficultySettings = false
    @State private var hapticEnabled = HapticService.shared.isHapticEnabled
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer().frame(height: 60)
                
                Spacer()
                
                VStack(spacing: 24) {
                    SettingsButton(
                        title: "Edit Profile",
                        icon: "person",
                        color: .gamePink,
                        action: {
                            showProfileEdit = true
                        }
                    )
                    SettingsButton(
                        title: "Sound Settings",
                        icon: "speaker.wave.3",
                        color: .gameBlue,
                        action: {
                            showSoundSettings = true
                        }
                    )
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
                            .fill(HapticService.supportsHaptics ? Color.gameOrange : Color.gameOrange.opacity(0.5))
                            .shadow(color: HapticService.supportsHaptics ? Color.gameOrange.opacity(0.5) : Color.gameOrange.opacity(0.2), radius: 5, x: 2, y: 2)
                    )
                    .frame(maxWidth: 350)
                    .onChange(of: hapticEnabled) { _, newValue in
                        HapticService.shared.toggleHaptic()
                        if newValue {
                            HapticService.shared.play(.medium)
                        }
                    }
                    SettingsButton(
                        title: "Difficulty Level",
                        icon: "puzzlepiece",
                        color: .gameGreen,
                        action: {
                            showDifficultySettings = true
                        }
                    )
                    SettingsButton(
                        title: "Reset Progress",
                        icon: "arrow.counterclockwise",
                        color: .gameRed,
                        action: {
                            showResetConfirmation = true
                        }
                    )
                }
                .padding()
                Spacer()
            }
            TopBar(title: "Settings", color: .gamePurple, infoButtonDisabled: true)

            if showResetConfirmation {
                TwoButtonInfoPopup(
                    title: "Reset Progress",
                    message: "Are you sure you want to reset all game progress? This will return all mini-games to their initial state as if you're playing them for the first time. This action cannot be undone.",
                    primaryButtonTitle: "Reset",
                    secondaryButtonTitle: "Cancel",
                    onPrimaryButtonTap: {
                        print("Before reset - Achievements: \(userViewModel.achievements)")
                        userViewModel.resetProgress()
                        print("After reset - Achievements: \(userViewModel.achievements)")
                        showResetConfirmation = false
                        showResetSuccess = true
                        HapticService.shared.play(.heavy)
                    },
                    onSecondaryButtonTap: {
                        showResetConfirmation = false
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
                        HapticService.shared.play(.light)
                    }
                )
            }
            
            if showProfileEdit {
                ProfileEditPopup(
                    isShowing: $showProfileEdit
                )
            }
            
            if showSoundSettings {
                SoundSettingsPopup(
                    isShowing: $showSoundSettings
                )
            }
            
            if showDifficultySettings {
                DifficultySettingsPopup(
                    isShowing: $showDifficultySettings
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
