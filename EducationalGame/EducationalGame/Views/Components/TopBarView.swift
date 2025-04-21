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
            CircleButton(iconName: leftIcon, color: .gameGray.opacity(0.8))
            
            Spacer()
            
            Text(title)
                .font(GameTheme.titleFont)
                .foregroundColor(color)
                .padding(.vertical, 30)
                .padding(.horizontal, 70)
                .transition(.scale)
            
            Spacer()
            
            CircleButton(iconName: rightIcon, color: .gameGray.opacity(0.8))
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity) // Makes sure it stretches across the screen
        .zIndex(1) // Ensures it stays above other content
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: title)
    }
}

#Preview {
    TopBarView(title: "Hello")
        .environmentObject(NavigationState())
}
