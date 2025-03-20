import SwiftUICore

struct GameConstants {
    static let miniGames: [MiniGame] = [
        MiniGame(id: 1, name: "Binary Game", icon: "number", color: .gameRed, view: AnyView(BinaryGameView()), highScore: 0),
        MiniGame(id: 2, name: "Pixel Game", icon: "photo.on.rectangle", color: .gameGreen, view: AnyView(PixelGameView()), highScore: 0),
        MiniGame(id: 3, name: "Color Game", icon: "paintpalette", color: .gameBlue, view: AnyView(ColorGameView()), highScore: 0)
    ]
}
