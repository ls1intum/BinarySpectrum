import SwiftUI

struct AnimatedCircleButton: View {
    var iconName: String
    var color: Color
    var action: () -> Void // Added action closure

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 90, height: 80) // Slightly reduced for better UI balance
                .shadow(color: color.opacity(0.6), radius: 8, x: 4, y: 4)

            Image(systemName: iconName)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                action()
            }
        }
    }
}



#Preview {
    AnimatedCircleButton(iconName: "plus", color: .blue, action: { })
}
