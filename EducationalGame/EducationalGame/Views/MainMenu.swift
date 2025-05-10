import SwiftUI

// Custom view modifier to hide navigation bar
struct HideNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)
    }
}

// Extension to make it easier to use
extension View {
    func hideNavigationBar() -> some View {
        modifier(HideNavigationBar())
    }
}

struct MainMenu: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationState: NavigationState
    @State private var startAnimation = false
    @State private var showWelcomePopup = false
    @State private var userName = ""
    @State private var userAge = ""
    @State private var favoriteColor: Color = .gamePurple
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            ZStack(alignment: .top) {
                VStack {
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Welcome message
                        if !userViewModel.userName.isEmpty {
                            (
                                Text("Welcome, ")
                                    .foregroundColor(.gameDarkBlue)
                                    + Text(userViewModel.userName)
                                    .foregroundColor(.gameDarkBlue) // or userViewModel.favoriteColor
                            )
                            .font(GameTheme.headingFont)
                            .foregroundColor(userViewModel.favoriteColor)
                            .scaleTransition()
                            .offset(y: startAnimation ? 0 : 50)
                            .opacity(startAnimation ? 1 : 0)
                        } else {
                            Text("Welcome!")
                                .font(GameTheme.headingFont)
                                .foregroundColor(.gameDarkBlue)
                                .scaleTransition()
                                .offset(y: startAnimation ? 0 : 50)
                                .opacity(startAnimation ? 1 : 0)
                        }
                        
                        HStack(spacing: 30) {
                            ForEach(GameConstants.miniGames) { game in
                                GameButton(
                                    gameId: game.id,
                                    color: game.color,
                                    icon: game.icon,
                                    title: game.name,
                                    navigationPath: $navigationState.path,
                                    destination: game.id
                                )
                                .scaleTransition()
                                .offset(y: startAnimation ? 0 : 50)
                                .opacity(startAnimation ? 1 : 0)
                            }
                        }
                        
                        // Bottom Buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                HapticService.shared.play(.selection)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigationState.path.append("achievements")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text("Achievements")
                                }
                                .font(GameTheme.headingFont)
                                .padding()
                                .frame(width: 480, height: 80)
                                .background(Color.gameYellow)
                                .foregroundColor(.gameBlack)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            }
                            .shadow(radius: 5)
                            .scaleTransition()
                            .offset(y: startAnimation ? 0 : 50)
                            .opacity(startAnimation ? 1 : 0)
                            
                            Button(action: {
                                HapticService.shared.play(.light)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigationState.path.append("challenges")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gamecontroller")
                                    Text("Challenges")
                                }
                                .font(GameTheme.headingFont)
                                .padding()
                                .frame(width: 480, height: 80)
                                .background(Color.gameOrange)
                                .foregroundColor(.gameWhite)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            }
                            .shadow(radius: 5)
                            .scaleTransition()
                            .offset(y: startAnimation ? 0 : 50)
                            .opacity(startAnimation ? 1 : 0)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                }
                
                TopBar(title: LocalizedStringResource(stringLiteral: GameConstants.gameTitle), leftIcon: "gear")
                    .offset(y: startAnimation ? 0 : -50)
                    .opacity(startAnimation ? 1 : 0)
            }
            .overlay {
                // Welcome popup
                if showWelcomePopup {
                    WelcomeFormPopup(
                        isShowing: $showWelcomePopup,
                        userName: $userName,
                        userAge: $userAge,
                        favoriteColor: $favoriteColor,
                        onSubmit: { name, age, color in
                            userViewModel.saveUserInfo(name: name, age: age, favoriteColor: color)
                            userViewModel.setFirstLaunchCompleted()
                            HapticService.shared.play(.success)
                        },
                        onSkip: {
                            userViewModel.saveUserInfo(name: userName, age: userAge, favoriteColor: favoriteColor)
                            userViewModel.setFirstLaunchCompleted()
                            HapticService.shared.play(.light)
                        }
                    )
                }
            }
            .edgesIgnoringSafeArea(.top)
            .hideNavigationBar()
            .navigationDestination(for: Int.self) { gameId in
                if let game = GameConstants.miniGames.first(where: { $0.id == gameId }) {
                    AnyView(game.view)
                        .environmentObject(navigationState)
                        .hideNavigationBar()
                        .slideTransition(edge: .trailing)
                } else {
                    Text("Game not found")
                        .hideNavigationBar()
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "achievements":
                    AchievementsView()
                        .environmentObject(navigationState)
                        .environmentObject(userViewModel)
                        .hideNavigationBar()
                        .slideTransition(edge: .bottom)
                case "settings":
                    SettingsView()
                        .environmentObject(navigationState)
                        .hideNavigationBar()
                        .slideTransition(edge: .leading)
                case "challenges":
                    ChallengesView()
                        .environmentObject(navigationState)
                        .hideNavigationBar()
                        .slideTransition(edge: .bottom)
                default:
                    Text("View not found")
                        .hideNavigationBar()
                }
            }
            .navigationDestination(for: ChallengeParams.self) { params in
                if let game = GameConstants.miniGames.first(where: { $0.id == params.miniGameId }) {
                    AnyView(game.view)
                        .environmentObject(navigationState)
                        .environment(\.challengeParams) { _ in
                            // Set the navigation state's challenge params directly
                            navigationState.challengeParams = params
                        }
                        .hideNavigationBar()
                        .slideTransition(edge: .trailing)
                } else {
                    Text("Challenge not found")
                        .hideNavigationBar()
                }
            }
        }
        .transition(.opacity)
        .onAppear {
            // Populaste fields with any existing data (in case popup reopens)
            userName = userViewModel.userName
            userAge = userViewModel.userAge
            favoriteColor = userViewModel.favoriteColor
            
            // Trigger animation immediately but with a very slight delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    startAnimation = true
                    HapticService.shared.play(.light)
                }
            }
            
            // Check if it's the first launch and show welcome popup after a delay
            if userViewModel.isFirstLaunch() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showWelcomePopup = true
                        HapticService.shared.play(.medium)
                    }
                }
            }
        }
    }
}

// Make ChallengeParams conform to Hashable
extension ChallengeParams: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(miniGameId)
        hasher.combine(challengeId)
        hasher.combine(phase)
        hasher.combine(returnToChallenges)
    }
    
    static func == (lhs: ChallengeParams, rhs: ChallengeParams) -> Bool {
        return lhs.miniGameId == rhs.miniGameId &&
            lhs.challengeId == rhs.challengeId &&
            lhs.phase == rhs.phase &&
            lhs.returnToChallenges == rhs.returnToChallenges
    }
}

#Preview {
    MainMenu()
        .environmentObject(UserViewModel())
        .environmentObject(NavigationState())
}

#Preview("BR") {
    MainMenu()
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .environmentObject(UserViewModel())
        .environmentObject(NavigationState())
}

#Preview("DE") {
    MainMenu()
        .environment(\.locale, Locale(identifier: "DE"))
        .environmentObject(UserViewModel())
        .environmentObject(NavigationState())
}
