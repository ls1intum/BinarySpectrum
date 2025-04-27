import SwiftUI

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
                // Background and content
                VStack {
                    // Top spacing to accommodate the TopBarView
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        // Welcome message positioned above the mini game buttons
                        if !userViewModel.userName.isEmpty {
                            (
                                Text("Welcome, ")
                                    .foregroundColor(.gameDarkBlue)
                                    + Text(userViewModel.userName)
                                    .foregroundColor(userViewModel.favoriteColor)
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
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    navigationState.navigateTo("achievements")
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
                                print("Another Feature tapped!")
                            }) {
                                HStack {
                                    Image(systemName: "hammer")
                                    Text("More Features")
                                }
                                .font(GameTheme.headingFont)
                                .padding()
                                .frame(width: 480, height: 80)
                                .background(Color.gameOrange)
                                .foregroundColor(.gameWhite)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            }
                            .disabled(true)
                            .shadow(radius: 5)
                            .offset(y: startAnimation ? 0 : 50)
                            .opacity(startAnimation ? 1 : 0)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                }
                
                // TopBarView overlay at the top
                TopBar(title: GameConstants.gameTitle, leftIcon: "gear")
                    .offset(y: startAnimation ? 0 : -50)
                    .opacity(startAnimation ? 1 : 0)
            }
            .overlay {
                // Welcome popup - moved to overlay to prevent interaction issues
                if showWelcomePopup {
                    WelcomeFormPopup(
                        isShowing: $showWelcomePopup,
                        userName: $userName,
                        userAge: $userAge,
                        favoriteColor: $favoriteColor,
                        onSubmit: { name, age, color in
                            userViewModel.saveUserInfo(name: name, age: age, favoriteColor: color)
                            userViewModel.setFirstLaunchCompleted()
                        },
                        onSkip: {
                            // Still save any entered information
                            userViewModel.saveUserInfo(name: userName, age: userAge, favoriteColor: favoriteColor)
                            userViewModel.setFirstLaunchCompleted()
                        }
                    )
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationDestination(for: Int.self) { gameId in
                // This will navigate to the selected game view
                if let game = GameConstants.miniGames.first(where: { $0.id == gameId }) {
                    AnyView(game.view)
                        .environmentObject(navigationState)
                        .slideTransition(edge: .trailing)
                        .toolbar(.hidden, for: .navigationBar)
                } else {
                    Text("Game not found")
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "achievements" {
                    AchievementsView()
                        .environmentObject(navigationState)
                        .environmentObject(userViewModel)
                        .slideTransition(edge: .bottom)
                        .toolbar(.hidden, for: .navigationBar)
                } else if destination == "settings" {
                    SettingsView()
                        .environmentObject(navigationState)
                        .slideTransition(edge: .leading)
                        .toolbar(.hidden, for: .navigationBar)
                } else {
                    Text("View not found")
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar) // Also hide for the root view
        }
        .transition(.opacity)
        .onAppear {
            // Populate fields with any existing data (in case popup reopens)
            userName = userViewModel.userName
            userAge = userViewModel.userAge
            favoriteColor = userViewModel.favoriteColor
            
            // Trigger animation immediately but with a very slight delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    startAnimation = true
                }
            }
            
            // Check if it's the first launch and show welcome popup after a delay
            if userViewModel.isFirstLaunch() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showWelcomePopup = true
                    }
                }
            }
        }
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
