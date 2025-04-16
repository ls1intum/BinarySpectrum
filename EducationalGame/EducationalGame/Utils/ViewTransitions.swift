import SwiftUI

struct SlideTransition: ViewModifier {
    let direction: Edge
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction).combined(with: .opacity),
                    removal: .move(edge: direction.opposite).combined(with: .opacity)
                )
            )
            .animation(animation, value: UUID())
    }
}

struct ScaleTransition: ViewModifier {
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .transition(.scale(scale: 0.9).combined(with: .opacity))
            .animation(animation, value: UUID())
    }
}

// Extension to get the opposite edge
extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// View extensions to make it easy to apply transitions
extension View {
    func slideTransition(edge: Edge = .trailing, animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        modifier(SlideTransition(direction: edge, animation: animation))
    }
    
    func scaleTransition(animation: Animation = .spring(response: 0.4, dampingFraction: 0.7)) -> some View {
        modifier(ScaleTransition(animation: animation))
    }
} 