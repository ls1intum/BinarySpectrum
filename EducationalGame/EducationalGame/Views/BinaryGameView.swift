import SwiftUI

struct BinaryGameView: View {
    @State private var selectedBinary = ["0", "0", "0", "0"]
    @State private var targetNumber = 5
    @State private var message = ""
    
    func binaryToDecimal(_ binary: [String]) -> Int {
        return Int(binary.joined(), radix: 2) ?? 0
    }
    
    var body: some View {
        TopBarView(title: "Binary Game", color: .gameRed)
        VStack(spacing: 20) {
            Text("🟢 Convert to Binary")
                .font(.title)
            
            Text("Make the number \(targetNumber) in binary!")
                .font(.headline)
            
            HStack {
                ForEach(0..<selectedBinary.count, id: \.self) { index in
                    Button(action: {
                        selectedBinary[index] = (selectedBinary[index] == "0") ? "1" : "0"
                    }) {
                        Text(selectedBinary[index])
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
            }
            
            Button("Check") {
                if binaryToDecimal(selectedBinary) == targetNumber {
                    message = "✅ Correct!"
                } else {
                    message = "❌ Try Again!"
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text(message)
                .font(.title2)
                .foregroundColor(.red)
        }
        .padding()
    }
}

#Preview {
    BinaryGameView()
}
