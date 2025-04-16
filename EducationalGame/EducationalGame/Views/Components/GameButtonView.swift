import SwiftUI

struct GameButtonView: View {
    let gameId: Int
    let color: Color
    let icon: String
    let title: LocalizedStringResource
    let destination: AnyView
    
    @State private var isPressed = false
    @EnvironmentObject private var navigationState: NavigationState
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
                
                // Add a slight delay before navigation to show the button animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigationState.navigateTo(gameId)
                    
                    // Reset button state after navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPressed = false
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
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(width: 320, height: 240)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle()) // Ensures no default button styling interferes
    }
}

#Preview {
    GameButtonView(gameId: 1, color: .gameBlue, icon: "plus", title: "Add", destination: AnyView(ContentView()))
        .environmentObject(NavigationState())
}
