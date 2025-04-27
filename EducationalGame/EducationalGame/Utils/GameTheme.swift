import SwiftUI

// A namespace for game-wide styling and theme constants
enum GameTheme {
    static let titleFont = Font.custom("LoveYaLikeASister-Regular", size: 75)
    static let subtitleFont = Font.custom("LoveYaLikeASister-Regular", size: 48)
    static let headingFont = Font.custom("LoveYaLikeASister-Regular", size: 36)
    static let subheadingFont = Font.custom("LoveYaLikeASister-Regular", size: 24)
    static let bodyFont = Font.custom("LoveYaLikeASister-Regular", size: 21)
    static let buttonFont = Font.custom("LoveYaLikeASister-Regular", size: 20)
    
    // Button style with consistent styling across the app
    struct PrimaryButtonStyle: ButtonStyle {
        let color: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(GameTheme.buttonFont)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
                .foregroundColor(.gameWhite)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        }
    }
    
    // Secondary button style
    struct SecondaryButtonStyle: ButtonStyle {
        let color: Color
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(GameTheme.buttonFont)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.clear)
                .foregroundColor(color.opacity(configuration.isPressed ? 0.7 : 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: 2)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
        }
    }
}
