import SwiftUI

struct CircleButton: View {
    var iconName: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.7))
                    .frame(width: 90, height: 90)
                    .shadow(radius: 5)
                
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(.black)
            }
            .scaleEffect(1.0)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    action()
                }
            }
        }
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton(iconName: "star.fill", color: .blue) {
            print("Button tapped!")
        }
    }
}
