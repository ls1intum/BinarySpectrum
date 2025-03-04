import SwiftUI

struct TopBarView: View {
    let title: LocalizedStringResource
    let color: Color
    let leftIcon: String
    let rightIcon: String
    
    init(
        title: LocalizedStringResource,
        color: Color = .gamePurple,
        leftIcon: String = "arrow.left",
        rightIcon: String = "info.circle"
    ) {
        self.title = title
        self.color = color
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
    }
    
    var body: some View {
        HStack {
            CircleButton(iconName: leftIcon, color: .gameGray.opacity(0.8)) {}
            
            Spacer()
            
            Text(title)
                .font(.custom("Poppins-Medium", size: 36))
                .foregroundColor(.white)
                .padding(.vertical, 30)
                .padding(.horizontal, 70)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(color.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        )
                )
            
            Spacer()
            
            CircleButton(iconName: rightIcon, color: .gameGray.opacity(0.8)) {}
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity) // Makes sure it stretches across the screen
        //.position(x: UIScreen.main.bounds.width / 2, y: 50) // Pins it at the top
        .zIndex(1) // Ensures it stays above other content
    }
}

#Preview {
    TopBarView(title: "Hello")
}
