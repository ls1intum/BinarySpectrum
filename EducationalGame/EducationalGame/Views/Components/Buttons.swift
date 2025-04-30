import SwiftUI

// MARK: - AnimatedCircleButton

struct AnimatedCircleButton: View {
    var iconName: String
    var color: Color = .gamePurple
    var action: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: 90, height: 90)
                .shadow(radius: 5)

            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(.gameWhite)
        }
        .scaleEffect(1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                action()
            }
        }
    }
}

// MARK: - CircleButton

struct CircleButton: View {
    var iconName: String
    var color: Color
    @Environment(\.currentView) var currentView
    @Environment(\.currentPhase) var currentPhase
    @EnvironmentObject private var navigationState: NavigationState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Button(action: handleAction) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.7))
                        .frame(width: 90, height: 90)
                        .shadow(radius: 5)

                    Image(systemName: iconName)
                        .font(.largeTitle)
                        .foregroundColor(.gameBlack)
                }
            }
        }
    }

    private func handleAction() {
        switch iconName {
        case "gear":
            withAnimation(.easeInOut(duration: 0.3)) {
                navigationState.navigateTo("settings")
            }
        case "arrow.left":
            withAnimation(.easeInOut(duration: 0.3)) {
                dismiss()
                // If dismiss doesn't work, try the navigation state's back function
                if navigationState.canGoBack {
                    navigationState.goBack()
                }
            }
        default:
            break
        }
    }
}

// MARK: - SquareButton

struct RewardButton: View {
    var miniGameIndex: Int
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isPressed = false
    @State private var navigateToAchievements = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPressed = true
                
                // Unlock the achievement for this mini-game
                // This would typically call an achievement service to mark the achievement as obtained
                // AchievementService.shared.unlockAchievement(for: miniGameIndex)
                
                // Navigate to the achievements view after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    navigateToAchievements = true
                    
                    // Reset the button state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPressed = false
                    }
                }
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(GameConstants.miniGames[miniGameIndex].color)
                    .frame(width: 90, height: 90)
                    .shadow(radius: isPressed ? 2 : 5)
                
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gameWhite)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $navigateToAchievements) {
            NavigationStack {
                AchievementsView()
                    .environmentObject(navigationState)
                    .environmentObject(userViewModel)
            }
        }
    }
}

// MARK: - InfoButton

struct InfoButton: View {
    @State private var showInfoPopup = false
    @Environment(\.currentView) var currentView
    @Environment(\.currentPhase) var currentPhase
    
    var body: some View {
        ZStack {
        Button(action: {
                showInfoPopup = true
        }) {
                ZStack {
                    Circle()
                        .fill(Color.gameGray.opacity(0.7))
                        .frame(width: 90, height: 90)
                        .shadow(radius: 5)

            Image(systemName: "info.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gameBlack)
                }
            }
        }
        .fullScreenCover(isPresented: $showInfoPopup) {
            ZStack {
                let view = currentView.isEmpty ? "MainMenu" : currentView
                let title = InfoButtonService.shared.getTitleForInfo(view: view, phase: currentPhase)
                let message = InfoButtonService.shared.getTip(for: view, phase: currentPhase) ?? 
                    "Welcome to the game! This informational popup provides context about your current screen."
                
                InfoPopup(
                    title: title,
                    message: message,
                    buttonTitle: "Got it!",
                    onButtonTap: {
                        showInfoPopup = false
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - Button Style for Scale Animation

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - GameButton

struct GameButton: View {
    let gameId: Int
    let color: Color
    let icon: String
    let title: LocalizedStringResource
    @Binding var navigationPath: NavigationPath
    let destination: Int

    @State private var isPressed = false
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true

                // Add a slight delay before navigation to show the button animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        navigationPath.append(destination)
                    }

                    // Reset button state after navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPressed = false
                        isHovered = false
                    }
                }
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
                    .foregroundColor(.gameWhite)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)

                Text(title)
                    .font(GameTheme.headingFont)
                    .foregroundColor(.gameWhite)
            }
            .frame(width: 320, height: 240)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: isPressed ? 2 : isHovered ? 8 : 5)
            .scaleEffect(isPressed ? 0.95 : isHovered ? 1.03 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .rotation3DEffect(
                .degrees(isHovered ? 2 : 0),
                axis: (x: -0.5, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Ensures no default button styling interferes
        .onTapGesture {} // Empty gesture to capture tap
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHovered {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isHovered = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isHovered = false
                    }
                }
        )
    }
}

// MARK: - Previews

#Preview("AnimatedCircleButton") {
    AnimatedCircleButton(iconName: "plus", action: {})
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircleButton(iconName: "gear", color: .blue)
                .environment(\.currentView, "MainMenu")
                .environment(\.currentPhase, .intro)
                .environmentObject(NavigationState())

            CircleButton(iconName: "arrow.left", color: .blue)
                .environment(\.currentView, "PixelGame")
                .environment(\.currentPhase, .challenges)
                .environmentObject(NavigationState())
        }
    }
}

#Preview("InfoButton") {
    InfoButton()
}

#Preview("GameButton") {
    NavigationStack {
        GameButton(
            gameId: 1,
            color: .blue,
            icon: "plus",
            title: "Add",
            navigationPath: .constant(NavigationPath()),
            destination: 1
        )
    }
}

#Preview("RewardButton") {
    RewardButton(
        miniGameIndex: 1
    )
    .environmentObject(NavigationState())
}
