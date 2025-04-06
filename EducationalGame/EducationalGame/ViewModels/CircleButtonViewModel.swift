import Foundation

@Observable class CircleButtonViewModel {
    var currentView: String
    var currentPhase: GamePhase
    
    init(currentView: String = "", currentPhase: GamePhase = .intro) {
        self.currentView = currentView
        self.currentPhase = currentPhase
    }
    
    func getInfoTitle() -> String {
        "\(currentView) - \(currentPhase.rawValue)"
    }
    
    func getInfoMessage() -> String {
        switch currentView {
        case "BinaryGame":
            return getBinaryGameMessage()
        case "PixelGame":
            return getPixelGameMessage()
        case "ColorGame":
            return getColorGameMessage()
        default:
            return getDefaultMessage()
        }
    }
    
    private func getBinaryGameMessage() -> String {
        switch currentPhase {
        case .intro:
            return "Welcome to the Binary Game! Here you'll learn how computers represent numbers using only 0s and 1s."
        case .questions:
            return "Test your understanding of binary numbers with these questions."
        case .exploration:
            return "Explore the binary world by converting decimal numbers to binary."
        case .challenges:
            return "Practice converting decimal numbers to binary by toggling the bits."
        case .reward:
            return "Congratulations on completing the Binary Game challenges!"
        }
    }
    
    private func getPixelGameMessage() -> String {
        switch currentPhase {
        case .intro:
            return "Welcome to the Pixel Game! Learn how digital images are made up of individual pixels."
        case .questions:
            return "Test your understanding of how pixels and binary work together to create images."
        case .exploration:
            return "Explore the pixel world by creating images with binary patterns."
        case .challenges:
            return "Create images by turning pixels on (1) and off (0) according to the binary pattern."
        case .reward:
            return "Great job completing the Pixel Game challenges!"
        }
    }
    
    private func getColorGameMessage() -> String {
        switch currentPhase {
        case .intro:
            return "Welcome to the Color Game! Learn how computers create colors using RGB values."
        case .questions:
            return "Test your knowledge about RGB color mixing."
        case .exploration:
            return "Explore the color world by mixing different amounts of Red, Green, and Blue."
        case .challenges:
            return "Mix different amounts of Red, Green, and Blue to create target colors."
        case .reward:
            return "Excellent work mastering RGB color mixing!"
        }
    }
    
    private func getDefaultMessage() -> String {
        return "This is an educational game designed to make learning computer concepts fun!"
    }
} 