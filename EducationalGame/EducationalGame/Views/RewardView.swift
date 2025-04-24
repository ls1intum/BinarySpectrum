import SwiftUI

struct RewardView: View {
    let message: String
    let personaImage: String
    let badgeTitle: String
    let color: Color
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var badgeOffset: CGFloat = 50
    @State private var badgeOpacity: Double = 0
    
    init(message: String, personaImage: String = GameConstants.miniGames[2].personaImage, badgeTitle: String = "Pixel Master!", color: Color = .gamePurple) {
        self.message = message
        self.personaImage = personaImage
        self.badgeTitle = badgeTitle
        self.color = color
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 30) {
                Spacer()
                
                // Main Content
                ZStack {
                    // Text Box
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gameGray)
                        .shadow(radius: 5)
                        .frame(width: 660, height: 250)
                    
                    // Text Inside Box
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
                    
                    // Character
                    Image(personaImage)
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
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                    
                    Text(badgeTitle)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 5)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gameGray.opacity(0.3))
                        .shadow(color: .yellow.opacity(0.3), radius: 10)
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
            
            // Continue Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CircleButton(
                        iconName: "trophy",
                        color: color
                    )
                    .padding()
                }
            }
        }
    }
}

#Preview {
    RewardView(
        message: "You've mastered storing black-and-white images and now colorful images too! Computers use these techniques to save memory and load images quickly. You're becoming a real computer scientist!",
        personaImage: GameConstants.miniGames[2].personaImage,
        badgeTitle: "Pixel Master! 🎖️"
    )
}
