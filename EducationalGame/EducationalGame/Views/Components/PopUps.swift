import SwiftUI

// MARK: - InfoPopup

struct InfoPopup: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let buttonTitle: LocalizedStringResource
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(title)
                    .font(GameTheme.headingFont)
                    .foregroundColor(.gamePurple)

                Text(message)
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                Button(action: {
                    HapticService.shared.play(.buttonTap)
                    onButtonTap()
                }) {
                    Text(buttonTitle)
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameWhite)
                        .padding()
                        .frame(width: 200)
                        .background(Color.gamePink)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .gesture(
            TapGesture().onEnded { _ in
                // Do nothing, prevents taps from passing through
            }
        )
    }
}

// MARK: - TwoButtonInfoPopup

struct TwoButtonInfoPopup: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let primaryButtonTitle: LocalizedStringResource
    let secondaryButtonTitle: LocalizedStringResource
    let onPrimaryButtonTap: () -> Void
    let onSecondaryButtonTap: () -> Void

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(title)
                    .font(GameTheme.headingFont)
                    .foregroundColor(.gamePurple)

                Text(message)
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    // Secondary button
                    Button(action: {
                        HapticService.shared.play(.light)
                        onSecondaryButtonTap()
                    }) {
                        Text(secondaryButtonTitle)
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 180)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }

                    // Primary button
                    Button(action: {
                        HapticService.shared.play(.medium)
                        onPrimaryButtonTap()
                    }) {
                        Text(primaryButtonTitle)
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 180)
                            .background(Color.gameRed)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - WelcomeFormPopup

struct WelcomeFormPopup: View {
    @Binding var isShowing: Bool
    @Binding var userName: String
    @Binding var userAge: String
    @Binding var favoriteColor: Color
    let onSubmit: (String, String, Color) -> Void
    let onSkip: () -> Void

    // Focus state to update as the placement of focus within the scene changes
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool

    // Local state to ensure values persist
    @State private var localUserName: String = ""
    @State private var localUserAge: String = ""
    @State private var localFavoriteColor: Color = .gamePurple

    private let colorOptions: [(Color, String)] = [
        (.gamePurple, "Purple"),
        (.gameBlue, "Blue"),
        (.gameGreen, "Green"),
        (.gameYellow, "Yellow"),
        (.gameOrange, "Orange"),
        (.gameRed, "Red"),
        (.gamePink, "Pink"),
        // (.gameGray, "Gray"),
        // (.gameWhite, "White"),
        // (.gameBlack, "Black"),
        // (.gameBrown, "Brown")
    ]

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    nameFieldFocused = false
                    ageFieldFocused = false
                }

            VStack(spacing: 16) {
                Text("Welcome to \(GameConstants.gameTitle)")
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.gamePurple)

                Text(GameConstants.gameDescription)
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Name")
                            .font(GameTheme.headingFont)
                            .foregroundColor(.gameDarkBlue)

                        TextField("Enter your name", text: $localUserName)
                            .font(GameTheme.bodyFont)
                            .padding()
                            .frame(width: 300)
                            .background(Color.gameWhite)
                            .cornerRadius(10)
                            .autocorrectionDisabled(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gameLightBlue, lineWidth: 2)
                            )
                            .focused($nameFieldFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                nameFieldFocused = false
                                ageFieldFocused = true
                                HapticService.shared.play(.selection)
                            }
                            .onChange(of: localUserName) {
                                userName = localUserName
                            }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Age")
                            .font(GameTheme.headingFont)
                            .foregroundColor(.gameDarkBlue)

                        TextField("Age", text: $localUserAge)
                            .font(GameTheme.bodyFont)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: 150)
                            .background(Color.gameWhite)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gameLightBlue, lineWidth: 2)
                            )
                            .focused($ageFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                ageFieldFocused = false
                                HapticService.shared.play(.selection)
                            }
                            .onChange(of: localUserAge) {
                                userAge = localUserAge
                            }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .center, spacing: 8) {
                    Text("Your Favorite Color")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameDarkBlue)

                    HStack(spacing: 12) {
                        Spacer()
                        ForEach(colorOptions, id: \.1) { color, name in
                            Button(action: {
                                localFavoriteColor = color
                                favoriteColor = color
                                HapticService.shared.play(.light)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .shadow(radius: 2)

                                    if localFavoriteColor == color {
                                        Circle()
                                            .strokeBorder(Color.gameWhite, lineWidth: 3)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .accessibilityLabel(name)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button(action: {
                        // Update parent bindings before dismissing
                        userName = localUserName
                        userAge = localUserAge
                        favoriteColor = localFavoriteColor
                        HapticService.shared.play(.light)
                        onSkip()
                        isShowing = false
                    }) {
                        Text("Skip")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 160)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }
                    Button(action: submitForm) {
                        Text("Start Playing")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 160)
                            .background(Color.gameDarkBlue)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                nameFieldFocused = false
                ageFieldFocused = false
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: isShowing)
        .onAppear {
            localUserName = userName
            localUserAge = userAge
            localFavoriteColor = favoriteColor
        }
    }

    private func submitForm() {
        // Make sure the bindings are updated with current values
        userName = localUserName
        userAge = localUserAge
        favoriteColor = localFavoriteColor

        HapticService.shared.play(.success)

        onSubmit(localUserName, localUserAge, localFavoriteColor)
        isShowing = false
    }
}

// MARK: - ProfileEditPopup

struct ProfileEditPopup: View {
    @Binding var isShowing: Bool
    @StateObject private var userViewModel = UserViewModel()
    @State private var userName: String = ""
    @State private var userAge: String = ""
    @State private var favoriteColor: Color = .gamePurple

    // Focus state to update as the placement of focus within the scene changes
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool

    private let colorOptions: [(Color, String)] = [
        (.gamePurple, "Purple"),
        (.gameBlue, "Blue"),
        (.gameGreen, "Green"),
        (.gameYellow, "Yellow"),
        (.gameOrange, "Orange"),
        (.gameRed, "Red"),
        (.gamePink, "Pink"),
    ]

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    nameFieldFocused = false
                    ageFieldFocused = false
                }

            VStack(spacing: 16) {
                Text("Edit Your Profile")
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.gamePink)

                Text("Update your profile information")
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Name")
                            .font(GameTheme.headingFont)
                            .foregroundColor(.gameDarkBlue)

                        TextField("Enter your name", text: $userName)
                            .font(GameTheme.bodyFont)
                            .padding()
                            .frame(width: 300)
                            .background(Color.gameWhite)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gameLightBlue, lineWidth: 2)
                            )
                            .focused($nameFieldFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                nameFieldFocused = false
                                ageFieldFocused = true
                                HapticService.shared.play(.selection)
                            }
                            .autocorrectionDisabled(true)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Age")
                            .font(GameTheme.headingFont)
                            .foregroundColor(.gameDarkBlue)

                        TextField("Age", text: $userAge)
                            .font(GameTheme.bodyFont)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: 150)
                            .background(Color.gameWhite)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gameLightBlue, lineWidth: 2)
                            )
                            .focused($ageFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                ageFieldFocused = false
                                HapticService.shared.play(.selection)
                            }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .center, spacing: 8) {
                    Text("Your Favorite Color")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameDarkBlue)

                    HStack(spacing: 12) {
                        Spacer()
                        ForEach(colorOptions, id: \.1) { color, name in
                            Button(action: {
                                favoriteColor = color
                                HapticService.shared.play(.light)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                        .shadow(radius: 2)

                                    if favoriteColor == color {
                                        Circle()
                                            .strokeBorder(Color.gameWhite, lineWidth: 3)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            .accessibilityLabel(name)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button(action: {
                        HapticService.shared.play(.light)
                        isShowing = false
                    }) {
                        Text("Cancel")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 120)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }
                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 160)
                            .background(Color.gameDarkBlue)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePink, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                nameFieldFocused = false
                ageFieldFocused = false
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: isShowing)
        .onAppear {
            userName = userViewModel.userName
            userAge = userViewModel.userAge
            favoriteColor = userViewModel.favoriteColor
        }
    }

    private func saveProfile() {
        HapticService.shared.play(.success)

        userViewModel.saveUserInfo(
            name: userName,
            age: userAge,
            favoriteColor: favoriteColor
        )
        isShowing = false
    }
}

// MARK: - SoundSettingsPopup

struct SoundSettingsPopup: View {
    @Binding var isShowing: Bool
    @State private var soundEnabled = SoundService.shared.isSoundEnabled
    @State private var musicEnabled = SoundService.shared.isMusicEnabled
    @State private var soundVolume = Double(SoundService.shared.soundVolume)
    @State private var musicVolume = Double(SoundService.shared.musicVolume)

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // Prevent dismissal on background tap
                }

            VStack(spacing: 16) {
                Text("Sound Settings")
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.gameBlue)

                Text("Adjust your sound and music preferences")
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                Divider()
                    .background(Color.gameLightBlue.opacity(0.5))
                    .padding(.horizontal)

                VStack(spacing: 20) {
                    // Sound Effects Settings
                    VStack(spacing: 12) {
                        HStack {
                            Text("Sound Effects")
                                .font(GameTheme.headingFont)
                                .foregroundColor(.gameDarkBlue)

                            Spacer()

                            Toggle("", isOn: $soundEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .gameGreen))
                                .labelsHidden()
                                .onChange(of: soundEnabled) { _, newValue in
                                    SoundService.shared.toggleSound()
                                    if newValue {
                                        SoundService.shared.playSound(.toggleSwitch)
                                    }
                                }
                        }

                        HStack(spacing: 15) {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(soundEnabled ? .gameDarkBlue : .gameGray)

                            Slider(value: $soundVolume, in: 0...1, step: 0.05)
                                .tint(.gameBlue)
                                .disabled(!soundEnabled)
                                .onChange(of: soundVolume) { _, newValue in
                                    SoundService.shared.setSoundVolume(newValue)
                                    if soundEnabled {
                                        SoundService.shared.playSound(.buttonTap)
                                    }
                                }

                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(soundEnabled ? .gameDarkBlue : .gameGray)
                        }
                        .opacity(soundEnabled ? 1.0 : 0.5)
                    }
                    .padding(.horizontal)

                    Divider()
                        .background(Color.gameLightBlue.opacity(0.5))
                        .padding(.horizontal)

                    // Background Music Settings
                    VStack(spacing: 12) {
                        HStack {
                            Text("Background Music")
                                .font(GameTheme.headingFont)
                                .foregroundColor(.gameDarkBlue)

                            Spacer()

                            Toggle("", isOn: $musicEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .gameGreen))
                                .labelsHidden()
                                .onChange(of: musicEnabled) { _, newValue in
                                    SoundService.shared.toggleMusic()
                                    if newValue && soundEnabled {
                                        SoundService.shared.playSound(.toggleSwitch)
                                    }
                                }
                        }

                        HStack(spacing: 15) {
                            Image(systemName: "music.note")
                                .foregroundColor(musicEnabled ? .gameDarkBlue : .gameGray)

                            Slider(value: $musicVolume, in: 0...1, step: 0.05)
                                .tint(.gameBlue)
                                .disabled(!musicEnabled)
                                .onChange(of: musicVolume) { _, newValue in
                                    SoundService.shared.setMusicVolume(newValue)
                                    if soundEnabled {
                                        SoundService.shared.playSound(.buttonTap)
                                    }
                                }

                            Image(systemName: "music.note.list")
                                .foregroundColor(musicEnabled ? .gameDarkBlue : .gameGray)
                        }
                        .opacity(musicEnabled ? 1.0 : 0.5)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                Button(action: {
                    if soundEnabled {
                        SoundService.shared.playSound(.buttonTap)
                    }
                    isShowing = false
                }) {
                    Text("Done")
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameWhite)
                        .padding()
                        .frame(width: 160)
                        .background(Color.gameDarkBlue)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gameBlue, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: isShowing)
    }
}

// MARK: - DifficultySettingsPopup

struct DifficultySettingsPopup: View {
    @Binding var isShowing: Bool
    @StateObject private var userViewModel = sharedUserViewModel
    @State private var autoAdjust: Bool
    @State private var binaryGameLevel: ExperienceLevel
    @State private var pixelArtGameLevel: ExperienceLevel
    @State private var colorGameLevel: ExperienceLevel

    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
        // Default to true if not set, otherwise use the saved value
        let savedAutoAdjust = sharedUserViewModel.autoAdjustExperienceLevel
        self._autoAdjust = State(initialValue: savedAutoAdjust)
        self._binaryGameLevel = State(initialValue: sharedUserViewModel.getExperienceLevel(for: "Binary Game"))
        self._pixelArtGameLevel = State(initialValue: sharedUserViewModel.getExperienceLevel(for: "Pixel Art Game"))
        self._colorGameLevel = State(initialValue: sharedUserViewModel.getExperienceLevel(for: "Color Game"))
    }

    var body: some View {
        ZStack {
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // Prevent dismissal on background tap
                }

            VStack(spacing: 16) {
                Text("Difficulty Settings")
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.gameGreen)

                Text("Adjust the experience level for each mini-game or let the game choose.")
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                Divider()
                    .background(Color.gameLightBlue.opacity(0.5))
                    .padding(.horizontal)

                // Auto-adjust toggle
                HStack {
                    Text("Auto-adjust Experience Level")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameDarkBlue)
                    Spacer()
                    Toggle("", isOn: $autoAdjust)
                        .toggleStyle(SwitchToggleStyle(tint: .gameGreen))
                        .labelsHidden()
                        .onChange(of: autoAdjust) { _, _ in
                            HapticService.shared.play(.selection)
                        }
                }
                .padding(.horizontal)

                VStack(spacing: 15) {
                    Text("Manual Settings")
                        .font(GameTheme.subheadingFont)
                        .foregroundColor(.gameDarkBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(autoAdjust ? 0.5 : 1)

                    GameDifficultySelectorRow(
                        gameName: "Binary Game",
                        selectedLevel: $binaryGameLevel,
                        disabled: autoAdjust
                    )
                    GameDifficultySelectorRow(
                        gameName: "Pixel Art Game",
                        selectedLevel: $pixelArtGameLevel,
                        disabled: autoAdjust
                    )
                    GameDifficultySelectorRow(
                        gameName: "Color Game",
                        selectedLevel: $colorGameLevel,
                        disabled: autoAdjust
                    )
                }
                .disabled(autoAdjust)
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button(action: {
                        isShowing = false
                        HapticService.shared.play(.light)
                    }) {
                        Text("Cancel")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 120)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }
                    Button(action: {
                        userViewModel.setAutoAdjustExperienceLevel(autoAdjust)
                        if !autoAdjust {
                            userViewModel.setExperienceLevel(binaryGameLevel, for: "Binary Game")
                            userViewModel.setExperienceLevel(pixelArtGameLevel, for: "Pixel Art Game")
                            userViewModel.setExperienceLevel(colorGameLevel, for: "Color Game")
                        }
                        isShowing = false
                        HapticService.shared.play(.success)
                    }) {
                        Text("Save")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 160)
                            .background(Color.gameGreen)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gameGreen, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: isShowing)
    }
}

private struct GameDifficultySelectorRow: View {
    let gameName: String
    @Binding var selectedLevel: ExperienceLevel
    let disabled: Bool
    var body: some View {
        HStack {
            Text(gameName)
                .font(GameTheme.bodyFont)
                .foregroundColor(.gameDarkBlue)
                .opacity(disabled ? 0.5 : 1)
            Spacer()
            Picker("", selection: $selectedLevel) {
                Text("Rookie").tag(ExperienceLevel.rookie)
                Text("Pro").tag(ExperienceLevel.pro)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1)
        }
    }
}

// MARK: - Previews

#Preview("InfoPopup") {
    InfoPopup(title: "Information", message: "This is an important message for the user that requires attention.", buttonTitle: "OK", onButtonTap: {})
}

#Preview("TwoButtonInfoPopup") {
    TwoButtonInfoPopup(
        title: "Confirm Action",
        message: "Are you sure you want to proceed with this action?",
        primaryButtonTitle: "Confirm",
        secondaryButtonTitle: "Cancel",
        onPrimaryButtonTap: {},
        onSecondaryButtonTap: {}
    )
}

#Preview("WelcomeFormPopup") {
    WelcomeFormPopup(
        isShowing: .constant(true),
        userName: .constant(""),
        userAge: .constant(""),
        favoriteColor: .constant(.gamePurple),
        onSubmit: { _, _, _ in },
        onSkip: {}
    )
    // .environment(\.locale, Locale(identifier: "DE"))
}

#Preview("ProfileEditPopup") {
    ProfileEditPopup(
        isShowing: .constant(true)
    )
}

#Preview("SoundSettingsPopup") {
    SoundSettingsPopup(
        isShowing: .constant(true)
    )
}

#Preview("DifficultySettingsPopup") {
    DifficultySettingsPopup(
        isShowing: .constant(true)
    )
}
