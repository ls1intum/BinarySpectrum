import SwiftUI

// MARK: - TopBar

struct TopBar: View {
    let title: LocalizedStringResource
    let color: Color
    let leftIcon: String
    let infoButtonDisabled: Bool
    
    init(
        title: LocalizedStringResource,
        color: Color = .gamePurple,
        leftIcon: String = "arrow.left",
        infoButtonDisabled: Bool = false
    ) {
        self.title = title
        self.color = color
        self.leftIcon = leftIcon
        self.infoButtonDisabled = infoButtonDisabled
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
            
            if !infoButtonDisabled {
                InfoButton()
                    .environment(\.currentView, title.key)
                    .environment(\.currentPhase, .introDialogue)
            }
            else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 90, height: 90)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .zIndex(1)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: title)
    }
}

// MARK: - InstructionBar

struct InstructionBar: View {
    let text: LocalizedStringResource
    var body: some View {
        Text(text)
            .font(GameTheme.subheadingFont)
            .foregroundColor(Color.gameDarkBlue)
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
            .multilineTextAlignment(.center)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gameGray)
                    .shadow(color: Color.gameBlack.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gameWhite.opacity(0.4), lineWidth: 2)
                    )
            )
            .frame(maxWidth: 1000)
    }
}

// MARK: - Previews

#Preview("TopBar") {
    TopBar(title: "Hello")
        .environmentObject(NavigationState())
}

#Preview("InstructionBar") {
    InstructionBar(text: """
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. 
    At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
    """)
    InstructionBar(text: """
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
    """)
}
