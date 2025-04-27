import SwiftUI

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
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
            )
            .frame(maxWidth: 1000)
    }
}

#Preview {
    InstructionBar(text: """
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. 
    At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
    """)
    InstructionBar(text: """
    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. 
    """)
}
