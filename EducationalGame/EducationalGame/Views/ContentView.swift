import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var selectedGame: MiniGame? // Track selected game
    
    var body: some View {
        VStack {
            TopBarView(title: "Educational Game", leftIcon: "gear")
            
            VStack(spacing: 40) {
                Spacer()
                HStack(spacing: 30) {
                    ForEach(GameConstants.miniGames) { game in
                        GameButtonView(gameId: game.id, color: game.color, icon: game.icon, title: game.name, destination: game.view)
                    }
                }
                
                // Bottom Buttons (Achievements & Another Feature)
                HStack(spacing: 20) {
                    Button(action: {
                        print("Achievements tapped!")
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
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("BR") {
    ContentView()
        .environment(\.locale, Locale(identifier: "pt_BR"))
}
