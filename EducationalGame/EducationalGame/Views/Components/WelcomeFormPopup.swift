import SwiftUI

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
        (.gamePink, "Pink")
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
                
                Text("We're excited to have you join us! This game offers 3 fun mini-games that will challenge your mind while you learn about computational thinking.")
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
        .transition(.opacity)
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
        
        onSubmit(localUserName, localUserAge, localFavoriteColor)
        isShowing = false
    }
}

#Preview {
    WelcomeFormPopup(
        isShowing: .constant(true),
        userName: .constant(""),
        userAge: .constant(""),
        favoriteColor: .constant(.gamePurple),
        onSubmit: { _, _, _ in },
        onSkip: {}
    )
}
