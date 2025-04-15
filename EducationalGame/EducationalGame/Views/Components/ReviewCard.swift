import SwiftUI

struct ReviewCard: View {
    let title: String
    let content: String
    let example: String
    let titleColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(GameTheme.subtitleFont)
                .bold()
                .foregroundColor(titleColor)

            Text(content)
                .font(GameTheme.bodyFont)

            Text(example)
                .font(.system(.body, design: .monospaced))
                .padding(10)
                .background(Color.gameGray.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.gameGray.opacity(0.1))
        .cornerRadius(15)
        .frame(maxWidth: 350)
    }
}

#Preview {
    ReviewCard(
        title: "Binary Basics",
        content: "Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'.",
        example: "101 = 1×4 + 0×2 + 1×1 = 5",
        titleColor: .gameRed
    )
    .padding()
}
