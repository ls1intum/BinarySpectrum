import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer().frame(height: 60)
                
                Spacer()
                
                // Tab selector for mini-games
                HStack(spacing: 20) {
                    ForEach(0 ..< GameConstants.miniGames.count, id: \.self) { index in
                        let game = GameConstants.miniGames[index]
                        MiniGameTab(
                            title: game.name,
                            color: game.color,
                            isSelected: viewModel.selectedMiniGame == index
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedMiniGame = index
                                HapticService.shared.play(.light)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Challenge tiles in a 3-2 grid layout
                VStack(spacing: 20) {
                    // Get the challenges for the selected mini-game
                    let challenges = viewModel.getChallengesForSelectedGame()
                    
                    // Top row - 3 challenges
                    HStack(spacing: 20) {
                        ForEach(challenges.prefix(3)) { challenge in
                            ChallengeTile(
                                challenge: challenge,
                                color: viewModel.getSelectedMiniGameColor(),
                                onTap: {
                                    HapticService.shared.play(.medium)
                                    viewModel.startChallenge(
                                        challenge: challenge,
                                        navigationState: navigationState
                                    )
                                }
                            )
                        }
                    }
                    
                    // Bottom row - 2 challenges
                    HStack(spacing: 20) {
                        Spacer()
                        
                        ForEach(challenges.suffix(2)) { challenge in
                            ChallengeTile(
                                challenge: challenge,
                                color: viewModel.getSelectedMiniGameColor(),
                                onTap: {
                                    HapticService.shared.play(.medium)
                                    viewModel.startChallenge(
                                        challenge: challenge,
                                        navigationState: navigationState
                                    )
                                }
                            )
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            TopBar(title: "Challenges", color: .gamePurple)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// Tab for selecting mini-games
struct MiniGameTab: View {
    let title: LocalizedStringResource
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(GameTheme.headingFont)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .black)
            .scaleEffect(isSelected ? 1.05 : 1)
            .shadow(radius: isSelected ? 3 : 0)
    }
}

// Challenge square tile component
struct ChallengeTile: View {
    let challenge: Challenge
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                // Icon
                Image(systemName: challenge.icon.isEmpty ? "gamecontroller.fill" : challenge.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(color)
                    )
                    .padding(.top, 15)
                
                // Title
                Text(challenge.name)
                    .font(GameTheme.subheadingFont)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                
                Spacer()
            }
            .frame(width: 240, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite)
                    .shadow(color: color.opacity(0.5), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChallengesView()
        .environmentObject(NavigationState())
}
