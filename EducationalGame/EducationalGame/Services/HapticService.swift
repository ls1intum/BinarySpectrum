import CoreHaptics
import Foundation
import SwiftUI
import UIKit

// MARK: - Haptic types

// Enum defining the type of haptic feedback
enum HapticType {
    // Notification types
    case success
    case warning
    case error
    
    // Impact types with varying intensities
    case light
    case medium
    case heavy
    
    // Selection feedback
    case selection
    
    // Custom pattern (implemented for complex sequences)
    case buttonTap
    case gameSuccess
    case gameError
    case achievement
}

// MARK: - Haptic Service

// A service class for managing haptic feedback throughout the app
final class HapticService {
    static var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    // Shared instance for singleton access
    static let shared = HapticService()
    
    // MARK: - Properties
    
    // Whether haptic feedback is enabled
    var isHapticEnabled: Bool {
        PersistenceManager.shared.loadBool(forKey: .hapticEnabled)
    }
    
    // MARK: - Initialization
    
    private init() {
        // Default to true if not already set
        if !PersistenceManager.shared.loadBool(forKey: .hapticEnabled) {
            PersistenceManager.shared.saveBool(true, forKey: .hapticEnabled)
        }
    }
    
    // MARK: - Public methods
    
    // Toggles haptic feedback on/off
    func toggleHaptic() {
        PersistenceManager.shared.saveBool(!isHapticEnabled, forKey: .hapticEnabled)
    }
    
    // Triggers haptic feedback of the specified type
    // - Parameter type: The type of haptic feedback to trigger
    func play(_ type: HapticType) {
        // Don't play haptics if they're disabled
        guard isHapticEnabled else { return }
        
        switch type {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .buttonTap:
            // Simple tap feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .gameSuccess:
            // Sequence of feedback for successful game action
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Add a medium impact after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
                impactGenerator.impactOccurred()
            }
        case .gameError:
            // Error notification followed by a medium impact
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .achievement:
            // Achievement unlock feedback - a sequence of haptics
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Series of impacts with increasing intensity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let lightGenerator = UIImpactFeedbackGenerator(style: .light)
                lightGenerator.impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
                    mediumGenerator.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
                        heavyGenerator.impactOccurred()
                    }
                }
            }
        }
    }
}

// MARK: - Button Extension for Haptic Feedback

// A reusable button style that includes haptic feedback
struct HapticButtonStyle: ButtonStyle {
    var hapticType: HapticType = .buttonTap
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    HapticService.shared.play(hapticType)
                }
            }
    }
}

// For backwards compatibility with existing ScaleButtonStyle
extension ScaleButtonStyle {
    // Add haptic feedback to the existing button style
    func withHapticFeedback(_ type: HapticType = .buttonTap) -> some ButtonStyle {
        HapticButtonStyle(hapticType: type)
    }
}
