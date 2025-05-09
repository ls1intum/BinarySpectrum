import SwiftUI

struct RewardView: View {
    let miniGameIndex: Int
    let message: LocalizedStringResource
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
                        .frame(width: 600, height: 250)
                    
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
                            SoundService.shared.playSound(.levelUp3)
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
                    ZStack {
                        // Glowing background effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.yellow, .orange.opacity(0.7), .clear]),
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(scale * 1.2)
                            .opacity(0.7)
                        
                        // Outer ring with shimmer effect
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .white, .yellow, .orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 5
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: .yellow.opacity(0.6), radius: 10, x: 0, y: 0)
                        
                        // Medal image with reflection
                        ZStack {
                            Image(systemName: "medal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange, .yellow.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            // Reflection highlight
                            Image(systemName: "medal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white.opacity(0.8), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .mask(
                                    Rectangle()
                                        .frame(width: 60, height: 30)
                                        .offset(x: -5, y: -15)
                                )
                        }
                        .shadow(color: .orange.opacity(0.5), radius: 5)
                        .scaleEffect(scale)
                    }
                    
                    // Achievement name with stylized text
                    Text(GameConstants.miniGames[miniGameIndex].achievementName)
                        .font(GameTheme.headingFont)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .white, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.7), radius: 5)
                        .padding(.horizontal)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            GameConstants.miniGames[miniGameIndex].color
                        )
                        .shadow(radius: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .gameYellow,
                                            GameConstants.miniGames[miniGameIndex].color,
                                            .gameYellow
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 5
                                )
                        )
                )
                .offset(y: badgeOffset)
                .opacity(badgeOpacity)
                .onAppear {
                    // Initial animation for the badge entrance
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        badgeOffset = 0
                        badgeOpacity = 1.0
                        scale = 1.0
                    }
                    
                    // Animate only the medal icon, not the entire badge
                    withAnimation(
                        .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        scale = 1.05
                    }
                    SoundService.shared.playSound(.badge)
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
    ZStack(alignment: .top) {
        VStack {
            Spacer().frame(height: 90)
            RewardView(miniGameIndex: 2, message: "Congratulations! You've mastered digital colors! You now understand RGB values, hex codes, and opacity. You know how computers create every color on your screen. Keep exploring the colorful world of digital art and design!")
                .environmentObject(NavigationState())
            Spacer()
        }
        TopBar(title: "ColorBloom", color: .gameBlue, leftIcon: "gear")
    }
    .edgesIgnoringSafeArea(.top)
}
