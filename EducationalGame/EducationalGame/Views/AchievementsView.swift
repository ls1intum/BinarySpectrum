import SwiftUI

struct AchievementsView: View {
    @State private var viewModel: AchievementsViewModel
    
    init(viewModel: AchievementsViewModel = AchievementsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background and content
            VStack {
                // Top spacing to accommodate the TopBarView
                Spacer().frame(height: 60)
                
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
            
            // TopBarView overlay at the top
            TopBar(title: "Achievements", color: .gamePurple)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct AchievementTile: View {
    let game: MiniGame
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(isUnlocked ? .gameYellow : .gameDarkBlue)
            
            Text(game.name)
                .font(GameTheme.headingFont)
                .foregroundColor(isUnlocked ? .gameYellow : .gameDarkBlue)
            
            Text(isUnlocked ? game.achievementName : "In Progress")
                .font(GameTheme.headingFont)
                .foregroundColor(isUnlocked ? .gameYellow : .gameDarkBlue)
        }
        .frame(width: 320, height: 240)
        .background(isUnlocked ? game.color : game.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(game.color, lineWidth: 2)
        )
        .shadow(radius: 5)
    }
}

#Preview {
    AchievementsView()
        .environmentObject(UserViewModel())
}
