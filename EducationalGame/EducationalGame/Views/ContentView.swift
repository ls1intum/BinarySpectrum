import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            VStack {
                TopBarView(title: "Educational Game", leftIcon: "gear")
                
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
                    
                    // Bottom Buttons (Achievements & Another Feature)
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
                            .padding()
                            .frame(width: 480, height: 80)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                        .scaleTransition()
                        
                        Button(action: {
                            print("Another Feature tapped!")
                        }) {
                            Text("More Features")
                                .padding()
                                .frame(width: 480, height: 80)
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                        .scaleTransition()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white.edgesIgnoringSafeArea(.all))
            }
            .navigationDestination(for: Int.self) { gameId in
                // This will navigate to the selected game view
                if let game = GameConstants.miniGames.first(where: { $0.id == gameId }) {
                    AnyView(game.view)
                        .environmentObject(navigationState)
                        .slideTransition(edge: .trailing)
                } else {
                    Text("Game not found")
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "achievements" {
                    AchievementsView()
                        .environmentObject(navigationState)
                        .slideTransition(edge: .bottom)
                } else if destination == "settings" {
                    SettingsView()
                        .environmentObject(navigationState)
                        .slideTransition(edge: .leading)
                } else {
                    Text("View not found")
                }
            }
            .navigationBarHidden(true)
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
