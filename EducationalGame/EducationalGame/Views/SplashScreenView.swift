import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var iconScale = 0.1
    @State private var titleOpacity = 0.0
    @State private var backgroundScale = 0.0
    
    let onFinished: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.gamePurple
                .scaleEffect(backgroundScale)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Game icon
                Image(systemName: "gamecontroller.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gameYellow)
                    .scaleEffect(iconScale)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Game title
                Text(GameConstants.gameTitle)
                    .font(GameTheme.titleFont)
                    .foregroundColor(.gameWhite)
                    .opacity(titleOpacity)
            }
        }
        .onAppear {
            animateSplash()
        }
    }
    
    private func animateSplash() {
        // Animate background
        withAnimation(.easeOut(duration: 0.6)) {
            backgroundScale = 1.0
        }
        
        // Animate icon with spring effect
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
            iconScale = 1.0
        }
        
        // Fade in title
        withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
            titleOpacity = 1.0
        }
        
        // Trigger transition to main app after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
} 