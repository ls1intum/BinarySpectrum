import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationState: NavigationState
    @State private var startAnimation = false
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            ZStack(alignment: .top) {
                // Background and content
                VStack {
                    // Top spacing to accommodate the TopBarView
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 40) {
                        Spacer()
                        HStack(spacing: 30) {
                            ForEach(GameConstants.miniGames) { game in
                                GameButtonWithNavigation(
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
                                .foregroundColor(.black)
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
                TopBarView(title: GameConstants.gameTitle, leftIcon: "gear")
                    .offset(y: startAnimation ? 0 : -50)
                    .opacity(startAnimation ? 1 : 0)
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
            // Add a small delay to ensure the animation happens after splash screen disappears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    startAnimation = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserViewModel())
        .environmentObject(NavigationState())
}

#Preview("BR") {
    ContentView()
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .environmentObject(UserViewModel())
        .environmentObject(NavigationState())
}
