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
    @State private var iconScale: CGFloat = 0.95
    
    var body: some View {
        VStack(spacing: 20) {
            // Trophy with enhanced visuals
            ZStack {
                // Glowing background effect (only visible when unlocked)
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.yellow, .orange.opacity(0.7), .clear]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 90, height: 90)
                    .opacity(isUnlocked ? 0.7 : 0)
                    .scaleEffect(iconScale)
                
                // Outer ring with shimmer effect
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isUnlocked ? .yellow : .gameDarkBlue.opacity(0.4),
                                isUnlocked ? .white : .gameDarkBlue.opacity(0.2),
                                isUnlocked ? .yellow : .gameDarkBlue.opacity(0.4),
                                isUnlocked ? .orange : .gameDarkBlue.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: isUnlocked ? .yellow.opacity(0.6) : .clear, radius: 5)
                    .scaleEffect(iconScale)
                
                // Trophy with gradient - this is the animated element
                ZStack {
                    // Trophy with gradient
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            isUnlocked ?
                                LinearGradient(
                                    colors: [.yellow, .orange, .yellow.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [.gameDarkBlue.opacity(0.7), .gameDarkBlue.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .shadow(color: isUnlocked ? .orange.opacity(0.5) : .clear, radius: 3)
                    
                    // Reflection highlight (only for unlocked)
                    if isUnlocked {
                        Image(systemName: "trophy.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                            .mask(
                                Rectangle()
                                    .frame(width: 40, height: 20)
                                    .offset(x: -5, y: -10)
                            )
                    }
                }
                .scaleEffect(iconScale)
            }
            
            // Game name
            Text(game.name)
                .font(GameTheme.headingFont)
                .foregroundColor(isUnlocked ? .gameWhite : .gameDarkBlue.opacity(0.8))
            
            // Achievement name with styled text
            Text(isUnlocked ? game.achievementName : "In Progress")
                .font(GameTheme.headingFont)
                .foregroundStyle(
                    isUnlocked ?
                        LinearGradient(
                            colors: [.yellow, .white, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [.gameDarkBlue.opacity(0.6), .gameDarkBlue.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .shadow(color: isUnlocked ? .orange.opacity(0.5) : .clear, radius: 3)
        }
        .padding(20)
        .frame(width: 320, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(isUnlocked ? game.color : game.color.opacity(0.1))
                // ].stroke(isUnlocked ? .gameYellow : game.color, lineWidth: 5)
                .shadow(radius: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    isUnlocked ? .gameYellow : game.color,
                                    isUnlocked ? game.color : game.color.opacity(0.1),
                                    isUnlocked ? .gameYellow : game.color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 5
                        )
                )
        )
        .onAppear {
            // Apply animation only for unlocked achievements
            if isUnlocked {
                withAnimation(
                    .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    iconScale = 1.05
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(UserViewModel())
}

#Preview("AchievementTile locked") {
    AchievementTile(game: GameConstants.miniGames[0], isUnlocked: false)
}
