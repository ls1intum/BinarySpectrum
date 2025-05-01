import SwiftUI

struct InfoPopup: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let buttonTitle: LocalizedStringResource
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
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
                    // Play haptic feedback
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

struct TwoButtonInfoPopup: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let primaryButtonTitle: LocalizedStringResource
    let secondaryButtonTitle: LocalizedStringResource
    let onPrimaryButtonTap: () -> Void
    let onSecondaryButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
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
                        // Play light haptic feedback for secondary action
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
                        // Play medium haptic feedback for primary action
                        HapticService.shared.play(.medium)
                        onPrimaryButtonTap()
                    }) {
                        Text(primaryButtonTitle)
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 180)
                            .background(Color.gamePink)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
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
        .transition(.scale.combined(with: .opacity))
    }
}

struct WelcomeFormPopup: View {
    @Binding var isShowing: Bool
    @Binding var userName: String
    @Binding var userAge: String
    @Binding var favoriteColor: Color
    let onSubmit: (String, String, Color) -> Void
    let onSkip: () -> Void

    // Add focus state
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool

    // Add local state to ensure values persist
    @State private var localUserName: String = ""
    @State private var localUserAge: String = ""
    @State private var localFavoriteColor: Color = .gamePurple

    // Available color options
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
            // Semi-transparent background overlay - capture all taps
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // Just unfocus fields when tapping background
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gameLightBlue, lineWidth: 2)
                            )
                            .focused($nameFieldFocused)
                            .submitLabel(.next)
                            .onSubmit {
                                nameFieldFocused = false
                                ageFieldFocused = true
                                // Play selection feedback when moving to next field
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
                                // Play selection feedback when completing field
                                HapticService.shared.play(.selection)
                            }
                            .onChange(of: localUserAge) {
                                userAge = localUserAge
                            }
                    }
                    .padding(.horizontal)
                }

                // Favorite color selection
                VStack(alignment: .center, spacing: 8) {
                    Text("Choose Your Favorite Color")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameDarkBlue)

                    // Center the color circles
                    HStack(spacing: 12) {
                        Spacer()
                        ForEach(colorOptions, id: \.1) { color, name in
                            Button(action: {
                                localFavoriteColor = color
                                favoriteColor = color
                                // Play light haptic feedback when selecting color
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

                // Buttons
                HStack(spacing: 20) {
                    // Skip button
                    Button(action: {
                        // Update parent bindings before dismissing
                        userName = localUserName
                        userAge = localUserAge
                        favoriteColor = localFavoriteColor
                        // Play light haptic feedback for skip action
                        HapticService.shared.play(.light)
                        onSkip()
                        isShowing = false
                    }) {
                        Text("Skip")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 120)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }

                    // Start button
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
            .padding(.horizontal, 150) // Make popup even narrower
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

    // Extract the submit action to a method
    private func submitForm() {
        // Make sure the bindings are updated with current values
        userName = localUserName
        userAge = localUserAge
        favoriteColor = localFavoriteColor

        // Play success haptic feedback for form submission
        HapticService.shared.play(.success)
        
        onSubmit(localUserName, localUserAge, localFavoriteColor)
        isShowing = false
    }
}

struct ProfileEditPopup: View {
    @Binding var isShowing: Bool
    @StateObject private var userViewModel = UserViewModel()
    @State private var userName: String = ""
    @State private var userAge: String = ""
    @State private var favoriteColor: Color = .gamePurple
    
    // Add focus state
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool
    
    // Available color options - same as WelcomeFormPopup
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
            // Semi-transparent background overlay - capture all taps
            Color.gameBlack.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    // Just unfocus fields when tapping background
                    nameFieldFocused = false
                    ageFieldFocused = false
                }

            VStack(spacing: 16) {
                Text("Edit Your Profile")
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.gamePurple)

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
                                // Play selection feedback when moving to next field
                                HapticService.shared.play(.selection)
                            }
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
                                // Play selection feedback when completing field
                                HapticService.shared.play(.selection)
                            }
                    }
                    .padding(.horizontal)
                }

                // Favorite color selection
                VStack(alignment: .center, spacing: 8) {
                    Text("Choose Your Favorite Color")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameDarkBlue)

                    // Center the color circles
                    HStack(spacing: 12) {
                        Spacer()
                        ForEach(colorOptions, id: \.1) { color, name in
                            Button(action: {
                                favoriteColor = color
                                // Play light haptic feedback when selecting color
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

                // Buttons
                HStack(spacing: 20) {
                    // Cancel button
                    Button(action: {
                        // Play light haptic feedback for cancel action
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

                    // Save button
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
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 150) // Make popup even narrower
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
            // Load current user data when form appears
            userName = userViewModel.userName
            userAge = userViewModel.userAge
            favoriteColor = userViewModel.favoriteColor
        }
    }

    // Extract the save action to a method
    private func saveProfile() {
        // Play success haptic feedback for form submission
        HapticService.shared.play(.success)
        
        userViewModel.saveUserInfo(
            name: userName,
            age: userAge,
            favoriteColor: favoriteColor
        )
        isShowing = false
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
}

#Preview("ProfileEditPopup") {
    ProfileEditPopup(
        isShowing: .constant(true)
    )
}
