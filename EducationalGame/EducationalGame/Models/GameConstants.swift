import SwiftUICore

struct GameConstants {
    static let gameTitle: LocalizedStringResource = "Educational Game"
    static let miniGames: [MiniGame] = [
        MiniGame(id: 1, name: "Binary Game", icon: "lightswitch.on", color: .gameGreen, personaImage: "Figma2", view: AnyView(BinaryGameView()), highScore: 0),
        MiniGame(id: 2, name: "Pixel Game", icon: "square.grid.3x3.middle.filled", color: .gameRed, personaImage: "Figma1", view: AnyView(PixelGameView()), highScore: 0),
        MiniGame(id: 3, name: "Color Game", icon: "paintpalette", color: .gameBlue, personaImage: "Figma3", view: AnyView(ColorGameView()), highScore: 0)
    ]
}
