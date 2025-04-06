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
        case .tutorial:
            return "Learn how to convert decimal numbers to binary step by step."
        case .practice:
            return "Practice converting decimal numbers to binary with guided exercises."
        case .challenges:
            return "Practice converting decimal numbers to binary by toggling the bits."
        case .advancedChallenges:
            return "Challenge yourself with more complex binary conversions under time pressure."
        case .finalChallenge:
            return "Final challenge: Convert numbers to binary with limited attempts."
        case .review:
            return "Review what you've learned about binary numbers and their importance in computing."
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
        case .tutorial:
            return "Learn how to create images using binary patterns step by step."
        case .practice:
            return "Practice creating images by turning pixels on and off."
        case .challenges:
            return "Create images by turning pixels on (1) and off (0) according to the binary pattern."
        case .advancedChallenges:
            return "Challenge yourself with more complex pixel patterns under time pressure."
        case .finalChallenge:
            return "Final challenge: Create complex pixel patterns with limited attempts."
        case .review:
            return "Review how binary patterns create digital images and their importance in computing."
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
        case .tutorial:
            return "Learn about opacity and how it affects colors in digital images."
        case .practice:
            return "Practice matching colors using RGB values."
        case .challenges:
            return "Mix different amounts of Red, Green, and Blue to create target colors."
        case .advancedChallenges:
            return "Challenge yourself with color matching under time pressure."
        case .finalChallenge:
            return "Final challenge: Match colors with limited attempts."
        case .review:
            return "Review how RGB values and opacity work together to create digital colors."
        case .reward:
            return "Excellent work mastering RGB color mixing!"
        }
    }
    
    private func getDefaultMessage() -> String {
        return "This is an educational game designed to make learning computer concepts fun!"
    }
} 