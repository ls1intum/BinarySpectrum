import SwiftUI

extension Color {
    static let gameBlue = Color(red: 0, green: 0.643, blue: 1)
    static let gameYellow = Color(red: 1, green: 0.815, blue: 0)
    static let gameGreen = Color(red: 0, green: 0.729, blue: 0.627)
    static let gameOrange = Color(red: 0.988, green: 0.506, blue: 0.282)
    static let gameRed = Color(red: 1, green: 0.384, blue: 0.4)
    static let gamePurple = Color(red: 0.506, green: 0.251, blue: 0.961)
    static let gameLightBlue = Color(red: 0.506, green: 0.83, blue: 0.98)
    static let gameDarkBlue = Color(red: 0.173, green: 0.243, blue: 0.313)
    static let gamePink = Color(red: 1, green: 0.447, blue: 0.824)
    static let gameBrown = Color(red: 0.628, green: 0.322, blue: 0.176)
    static let gameWhite = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let gameGray = Color(red: 0.878, green: 0.878, blue: 0.878)
    static let gameBlack = Color(red: 0.173, green: 0.173, blue: 0.173)

    // Convert Color to a string representation for storage
    var storageString: String {
        switch self {
        case .gamePurple: return "gamePurple"
        case .gameBlue: return "gameBlue"
        case .gameOrange: return "gameOrange"
        case .gameYellow: return "gameYellow"
        case .gameGreen: return "gameGreen"
        case .gamePink: return "gamePink"
        case .gameRed: return "gameRed"
        case .gameBrown: return "gameBrown"
        case .gameWhite: return "gameWhite"
        case .gameGray: return "gameGray"
        case .gameBlack: return "gameBlack"
        default: return "gamePurple"
        }
    }

    // Create Color from storage string
    init(fromStorage string: String) {
        switch string {
        case "gamePurple": self = .gamePurple
        case "gameBlue": self = .gameBlue
        case "gameOrange": self = .gameOrange
        case "gameYellow": self = .gameYellow
        case "gameGreen": self = .gameGreen
        case "gamePink": self = .gamePink
        case "gameRed": self = .gameRed
        case "gameBrown": self = .gameBrown
        case "gameWhite": self = .gameWhite
        case "gameGray": self = .gameGray
        case "gameBlack": self = .gameBlack
        default: self = .gamePurple
        }
    }
}
