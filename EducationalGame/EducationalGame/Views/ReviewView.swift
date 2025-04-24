import SwiftUI

struct ReviewItem: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let example: String
}

struct ReviewView: View {
    let title: String
    let items: [ReviewItem]
    let color: Color
    let onCompletion: () -> Void
    
    @State private var checkedItems: [UUID: Bool] = [:]
    @State private var completionScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Check off what you've learned about \(title)! Mark your understanding.")
            
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(items) { item in
                        ChecklistReviewCard(
                            title: item.title,
                            content: item.content,
                            example: item.example,
                            titleColor: color,
                            isChecked: checkedItemBinding(for: item.id)
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxHeight: .infinity)
            
            VStack {
                HStack {
                    Spacer()
                    
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: color,
                        action: {
                            onCompletion()
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
    }
    
    private func checkedItemBinding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { checkedItems[id, default: false] },
            set: { checkedItems[id] = $0 }
        )
    }
}

#Preview {
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
        color: .gamePurple,
        onCompletion: {}
    )
}
