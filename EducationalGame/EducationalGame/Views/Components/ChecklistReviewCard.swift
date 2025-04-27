import SwiftUI

struct ChecklistReviewCard: View {
    let title: String
    let content: String
    let example: String
    let titleColor: Color
    @Binding var isChecked: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var rotationDegrees: Double = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isChecked.toggle()
                    if isChecked {
                        scale = 1.1
                        rotationDegrees = 5
                        
                        // Play haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        // Reset animation after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                scale = 1.0
                                rotationDegrees = 0
                            }
                        }
                    }
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(titleColor, lineWidth: 2)
                        .frame(width: 28, height: 28)
                        .background(
                            isChecked 
                            ? RoundedRectangle(cornerRadius: 5).fill(titleColor.opacity(0.2)) 
                            : RoundedRectangle(cornerRadius: 5).fill(Color.clear)
                        )
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(titleColor)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Card content
            VStack(alignment: .leading, spacing: 15) {
                Text(title)
                    .font(GameTheme.subheadingFont)
                    .bold()
                    .foregroundColor(titleColor)
                
                Text(content)
                    .font(GameTheme.bodyFont)
                
                if !example.isEmpty {
                    Text(example)
                        .font(.system(.body, design: .monospaced))
                        .padding(10)
                        .background(Color.gameGray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gameGray.opacity(0.1))
        .cornerRadius(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width:800)
        .scaleEffect(scale)
        .rotationEffect(Angle(degrees: rotationDegrees))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isChecked ? titleColor : Color.clear, lineWidth: isChecked ? 2 : 0)
        )
        .shadow(color: isChecked ? titleColor.opacity(0.3) : Color.gameBlack.opacity(0.1), 
                radius: isChecked ? 8 : 5, 
                x: 0, 
                y: isChecked ? 3 : 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isChecked)
    }
}

#Preview {
    VStack {
        ChecklistReviewCard(
            title: "Binary Basics",
            content: "Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'.",
            example: "101 = 1×4 + 0×2 + 1×1 = 5",
            titleColor: .gameRed,
            isChecked: .constant(false)
        )
        .padding()
        
        ChecklistReviewCard(
            title: "Run-Length Encoding",
            content: "RLE is a compression technique that stores sequences of the same value as a count and a single value.",
            example: "AAABBC → 3A2B1C",
            titleColor: .blue,
            isChecked: .constant(true)
        )
        .padding()
    }
} 
