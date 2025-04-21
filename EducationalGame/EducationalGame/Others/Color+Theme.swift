import SwiftUI

extension Color {
    static let gameBlue = Color(red: 0, green: 0.643, blue: 1)
    static let gameYellow = Color(red: 0.988, green: 0.859, blue: 0.282)
    static let gameGreen = Color(red: 0, green: 0.729, blue: 0.627)
    static let gameOrange = Color(red: 0.988, green: 0.506, blue: 0.282)
    static let gameRed = Color(red: 1, green: 0.384, blue: 0.4)
    static let gamePurple = Color(red: 0.506, green: 0.251, blue: 0.961)
    static let gameLightBlue = Color(red: 0.506, green: 0.83, blue: 0.98)
    static let gameWhite = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let gameGray = Color(red: 0.878, green: 0.878, blue: 0.878)
    static let gameDarkBlue = Color(red: 0.173, green: 0.243, blue: 0.313)
}

struct GameTheme {
    static let titleFont = Font.custom("LoveYaLikeASister-Regular", size: 75)
    static let subtitleFont = Font.custom("LoveYaLikeASister-Regular", size: 24)
    static let bodyFont = Font.custom("LoveYaLikeASister-Regular", size: 21)
    static let buttonFont = Font.custom("Poppins-Medium", size: 20)
}
