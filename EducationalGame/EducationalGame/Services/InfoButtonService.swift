import Foundation
import SwiftUI

// Service for providing contextual information throughout the app
class InfoButtonService {
    // Shared instance for easy access
    static let shared = InfoButtonService()
    
    // Store predefined tip content for different views and phases
    private let gameInfoTips: [String: [GamePhase: String]] = [
        "MainMenu": [
            .intro: "Welcome to the Educational Game! Choose a mini-game to start learning about computer science fundamentals in a fun, interactive way."
        ],
        "Settings": [
            .intro: "Adjust game settings, reset progress, or check out information about this educational app."
        ]
    ]
    
    // Additional information that can be shown with more detail
    private let additionalInfo: [String: [String: String]] = [
        "BinaryGame": [
            "what_is_binary": "Binary is a number system that uses only two digits: 0 and 1. It's the foundation of all computing because electronic circuits can easily represent these two states (on/off, true/false).",
            "binary_to_decimal": "To convert binary to decimal, multiply each digit by its position value (powers of 2) and add them together. For example, 1011 = 1×8 + 0×4 + 1×2 + 1×1 = 11.",
            "decimal_to_binary": "To convert decimal to binary, divide the number by 2 repeatedly and note the remainders in reverse order. For example, 13 ÷ 2 = 6 remainder 1, 6 ÷ 2 = 3 remainder 0, 3 ÷ 2 = 1 remainder 1, 1 ÷ 2 = 0 remainder 1. So 13 in binary is 1101."
        ],
        "PixelGame": [
            "what_are_pixels": "Pixels (short for 'picture elements') are the tiny dots that make up digital images. Each pixel contains color information, and thousands or millions of pixels together create the images you see on screens.",
            "binary_images": "In their simplest form, digital images can be represented as binary patterns where 1 represents a colored pixel and 0 represents a blank/white pixel. This is how basic pixel art works.",
            "rle_compression": "Run-Length Encoding (RLE) is a simple form of data compression that reduces the size of repeating data. For example, instead of storing 'WWWWBBB', RLE would store 'W4B3', indicating 4 Whites followed by 3 Blacks."
        ],
        "ColorGame": [
            "rgb_model": "The RGB color model creates colors by mixing different amounts of Red, Green, and Blue light. Each component ranges from 0 (none) to 255 (maximum), allowing for over 16 million possible colors.",
            "hex_colors": "Hexadecimal color codes (like #FF0000 for red) represent RGB values in base-16. The first two digits represent red, the next two green, and the last two blue.",
            "alpha_channel": "The alpha channel controls transparency in digital images. Values range from 0.0 (completely transparent) to 1.0 (fully opaque), allowing objects to be partially see-through."
        ]
    ]
    
    // Get appropriate icon for info popups based on the current view
    func getIconForView(_ view: String) -> String {
        switch view {
        case "BinaryGame":
            return "binary.circle"
        case "PixelGame":
            return "square.grid.3x3.fill"
        case "ColorGame":
            return "paintpalette.fill"
        case "MainMenu":
            return "gamecontroller.fill"
        case "Settings":
            return "gear"
        default:
            return "info.circle.fill"
        }
    }
    
    // Get appropriate color for info popups based on the current view
    func getColorForView(_ view: String) -> Color {
        switch view {
        case "BinaryGame":
            return .gameGreen
        case "PixelGame":
            return .gameRed
        case "ColorGame":
            return .gameBlue
        case "Settings":
            return .gameOrange
        default:
            return .gamePurple
        }
    }
    
    // Get title for info popup based on view and phase
    func getTitleForInfo(view: String, phase: GamePhase) -> String {
        switch view {
        case "BinaryGame":
            return "Binary Number System - \(phase.rawValue)"
        case "PixelGame":
            return "Pixel Art & Graphics - \(phase.rawValue)"
        case "ColorGame":
            return "Digital Colors - \(phase.rawValue)"
        case "MainMenu":
            return "Educational Computing Game"
        case "Settings":
            return "Game Settings"
        default:
            return "Educational Game - \(phase.rawValue)"
        }
    }
    
    // Get detailed content for specific topics within each game
    func getDetailedInfo(for game: String, topic: String) -> String? {
        return additionalInfo[game]?[topic]
    }
    
    // Get a tip for current view and phase
    func getTip(for view: String, phase: GamePhase) -> String? {
        return gameInfoTips[view]?[phase]
    }
    
    // Show a detailed info popup for a specific topic
    func showDetailedInfoPopup(for game: String, topic: String, onButtonTap: @escaping () -> Void) -> InfoPopup? {
        guard let content = getDetailedInfo(for: game, topic: topic) else { return nil }
        
        return InfoPopup(
            title: topic.replacingOccurrences(of: "_", with: " ").capitalized,
            message: content,
            buttonTitle: "Got it!",
            onButtonTap: onButtonTap
        )
    }
} 
