import SwiftUI

struct ReviewView: View {
    let title: LocalizedStringResource
    let items: [ReviewItem]
    let color: Color
    let onCompletion: () -> Void
    
    @State private var checkedItems: [UUID: Bool] = [:]
    @State private var completionScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 0) {
            InstructionBar(text: "Check off what you've learned about \(title)!")
                .padding(.top, 30)
            
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(items) { item in
                        ChecklistReviewCard(
                            title: item.title,
                            content: item.content,
                            example: item.example,
                            color: color,
                            isChecked: checkedItemBinding(for: item.id)
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 10)
            .frame(maxHeight: .infinity)
            
            VStack {
                HStack {
                    Spacer()
                    
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: color,
                        action: {
                            HapticService.shared.play(.gameSuccess)
                            onCompletion()
                        },
                        hapticType: .success
                    )
                    .padding(.trailing, 20)
                }
            }
        }
    }
    
    private func checkedItemBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { checkedItems[id, default: false] },
            set: { checkedItems[id] = $0 }
        )
    }
}

struct ChecklistReviewCard: View {
    let title: LocalizedStringResource
    let content: LocalizedStringResource
    let example: LocalizedStringResource
    let color: Color
    @Binding var isChecked: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var rotationDegrees: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isChecked.toggle()
                
                if isChecked {
                    HapticService.shared.play(.selection)
                    scale = 1.1
                    rotationDegrees = 5
                    
                    // Reset animation after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.0
                            rotationDegrees = 0
                        }
                    }
                } else {
                    HapticService.shared.play(.light)
                }
            }
        }) {
            HStack(alignment: .top, spacing: 15) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(color, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(color)
                    }
                }
                
                // Card content
                VStack(alignment: .leading, spacing: 15) {
                    Text(title)
                        .font(GameTheme.subheadingFont)
                        .bold()
                        .foregroundColor(color)
                    
                    Text(content)
                        .font(GameTheme.bodyFont)
                        .foregroundColor(.gameBlack)
                    
                    if !String(localized: example).isEmpty {
                        Text(example)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.gameBlack)
                            .padding(10)
                            .background(Color.gameGray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .cornerRadius(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(width: 800)
            .scaleEffect(scale)
            .rotationEffect(Angle(degrees: rotationDegrees))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isChecked ? color : Color.clear, lineWidth: isChecked ? 2 : 0)
                    .fill(isChecked ? color.opacity(0.1) : .gameGray.opacity(0.1))
            )
            .shadow(color: isChecked ? color.opacity(0.3) : Color.gameBlack.opacity(0.1),
                    radius: isChecked ? 8 : 5,
                    x: 0,
                    y: isChecked ? 3 : 2)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isChecked)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack(alignment: .top) {
        VStack {
            Spacer().frame(height: 90)
            ReviewView(
                title: "Binary Images",
                items: [
                    ReviewItem(
                        title: "Binary Basics",
                        content: "Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'.",
                        example: "101 = 1×4 + 0×2 + 1×1 = 5"
                    ),
                    ReviewItem(
                        title: "Pixel Representation",
                        content: "In binary images, each pixel is represented by a 0 (white) or 1 (black).",
                        example: "00110011 = □□■■□□■■"
                    ),
                    ReviewItem(
                        title: "Run-Length Encoding",
                        content: "RLE is a compression technique that stores sequences of the same value as a count and a single value.",
                        example: "W3B2W3 = □□□■■□□□"
                    )
                ],
                color: .gameRed,
                onCompletion: {}
            )
            Spacer()
        }
        TopBar(title: "test", leftIcon: "gear")
    }
    .edgesIgnoringSafeArea(.top)
}

#Preview("ChecklistReviewCard") {
    VStack {
        ChecklistReviewCard(
            title: "Binary Basics",
            content: "Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'.",
            example: "101 = 1×4 + 0×2 + 1×1 = 5",
            color: .gameRed,
            isChecked: .constant(false)
        )
        .padding()
        
        ChecklistReviewCard(
            title: "Run-Length Encoding",
            content: "RLE is a compression technique that stores sequences of the same value as a count and a single value.",
            example: "AAABBC → 3A2B1C",
            color: .blue,
            isChecked: .constant(true)
        )
        .padding()
    }
}
