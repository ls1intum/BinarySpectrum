import SwiftUI

struct RewardView: View {
    let miniGameIndex: Int
    let message: String
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var badgeOffset: CGFloat = 50
    @State private var badgeOpacity: Double = 0
    @EnvironmentObject private var navigationState: NavigationState
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Main Content
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gameGray)
                        .shadow(radius: 5)
                        .frame(width: 660, height: 250)
                    
                    Text(message)
                        .font(GameTheme.bodyFont)
                        .foregroundColor(.gameDarkBlue)
                        .padding(40)
                        .frame(width: 600, alignment: .leading)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0)) {
                                opacity = 1.0
                            }
                        }
                    
                    Image(GameConstants.miniGames[miniGameIndex].personaImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .foregroundColor(Color.gameBlue)
                        .offset(x: -400)
                        .zIndex(1)
                }
                
                // Badge
                VStack(spacing: 15) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .shadow(color: .gameYellow.opacity(0.5), radius: 10)
                    
                    Text(GameConstants.miniGames[miniGameIndex].achievementName)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .gameYellow.opacity(0.5), radius: 5)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gameGray.opacity(0.3))
                        .shadow(color: .gameYellow.opacity(0.3), radius: 10)
                )
                .scaleEffect(scale)
                .offset(y: badgeOffset)
                .opacity(badgeOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        scale = 1.0
                        badgeOffset = 0
                        badgeOpacity = 1.0
                    }
                }
                 
                Spacer()
            }
            .padding()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RewardButton(miniGameIndex: miniGameIndex)
                        .padding(.trailing, 20)
                }
            }
        }
    }
}

#Preview {
    RewardView(miniGameIndex: 1, message: "Great job")
        .environmentObject(NavigationState())
}
