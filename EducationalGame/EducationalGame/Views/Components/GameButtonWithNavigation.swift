import SwiftUI

struct GameButtonWithNavigation: View {
    let gameId: Int
    let color: Color
    let icon: String
    let title: LocalizedStringResource
    @Binding var navigationPath: NavigationPath
    let destination: Int
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
                
                // Add a slight delay before navigation to show the button animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        navigationPath.append(destination)
                    }
                    
                    // Reset button state after navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPressed = false
                        isHovered = false
                    }
                }
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
                
                Text(title)
                    .font(GameTheme.subtitleFont)
                    .foregroundColor(.black)
            }
            .frame(width: 320, height: 240)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: isPressed ? 2 : isHovered ? 8 : 5)
            .scaleEffect(isPressed ? 0.95 : isHovered ? 1.03 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .rotation3DEffect(
                .degrees(isHovered ? 2 : 0),
                axis: (x: -0.5, y: 1.0, z: 0.0)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Ensures no default button styling interferes
        .onTapGesture {} // Empty gesture to capture tap
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHovered {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isHovered = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isHovered = false
                    }
                }
        )
    }
}

#Preview {
    NavigationStack {
        GameButtonWithNavigation(
            gameId: 1, 
            color: .blue, 
            icon: "plus", 
            title: "Add", 
            navigationPath: .constant(NavigationPath()),
            destination: 1
        )
    }
} 