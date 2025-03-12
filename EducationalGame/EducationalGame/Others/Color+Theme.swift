import SwiftUI

extension Color {
    static let gameBlue = Color(red: 0.29, green: 0.565, blue: 0.886)
    static let gameYellow = Color(red: 0.96, green: 0.77, blue: 0.094)
    static let gameGreen = Color(red: 0.435, green: 0.81, blue: 0.59)
    static let gameOrange = Color(red: 0.95, green: 0.6, blue: 0.29)
    static let gameRed = Color(red: 1, green: 0.435, blue: 0.38)
    static let gamePurple = Color(red: 0.6, green: 0.32, blue: 0.88)
    static let gameLightBlue = Color(red: 0.506, green: 0.83, blue: 0.98)
    static let gameWhite = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let gameGray = Color(red: 0.878, green: 0.878, blue: 0.878)
    static let gameDarkBlue = Color(red: 0.173, green: 0.243, blue: 0.313)
}

struct GameTheme {
    static let titleFont = Font.custom("Poppins-Medium", size: 24)
    static let bodyFont = Font.custom("Poppins-Medium", size: 18)
    static let buttonFont = Font.custom("Poppins-Medium", size: 20)
}
