import SwiftUI

struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel
    
    init(viewModel: AchievementsViewModel = AchievementsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack {
            TopBarView(title: "Achievements", color: .gameYellow)
            Spacer()
            HStack(spacing: 30) {
                ForEach(GameConstants.miniGames) { game in
                    AchievementTile(
                        game: game,
                        isUnlocked: viewModel.isAchievementUnlocked(forGameId: game.id)
                    )
                }
            }
            Spacer()
        }
    }
}

struct AchievementTile: View {
    let game: MiniGame
    let isUnlocked: Bool
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Trophy Icon
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(isUnlocked ? .yellow : .gray)
            
            // Achievement Title
            Text(game.name)
                .font(.headline)
                .foregroundColor(.black)
            
            // Achievement Description
            Text(isUnlocked ? "Completed!" : "In Progress")
                .font(.subheadline)
                .foregroundColor(isUnlocked ? .green : .gray)
        }
        .frame(width: 320, height: 240)
        .background(isUnlocked ? game.color : game.color.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(game.color, lineWidth: 3)
        )
        .shadow(radius: isPressed ? 2 : 5)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPressed = false
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(UserViewModel())
}
