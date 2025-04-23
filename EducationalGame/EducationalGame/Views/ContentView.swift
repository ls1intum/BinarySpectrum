import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            VStack {
                TopBarView(title: GameConstants.gameTitle, leftIcon: "gear")
                
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
                            .font(GameTheme.subtitleFont)
                            .padding()
                            .frame(width: 480, height: 80)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                        .shadow(radius: 2)
                        .scaleTransition()
                        
                        Button(action: {
                            print("Another Feature tapped!")
                        }) {
                            HStack {
                                Image(systemName: "hammer.circle.fill")
                                Text("More Features")
                            }
                            .font(GameTheme.subtitleFont)
                            .padding()
                            .frame(width: 480, height: 80)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                        .shadow(radius: 2)
                        .scaleTransition()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
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
