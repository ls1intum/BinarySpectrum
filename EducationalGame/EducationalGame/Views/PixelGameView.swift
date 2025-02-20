import SwiftUI

struct PixelGameView: View {
    @State private var inputString = "BBBBWWBBB"
    @State private var compressedString = ""
    
    func runLengthEncoding(_ input: String) -> String {
        var result = ""
        var count = 1
        let chars = Array(input)
        
        for i in 1..<chars.count {
            if chars[i] == chars[i - 1] {
                count += 1
            } else {
                result += "\(count)\(chars[i - 1])"
                count = 1
            }
        }
        result += "\(count)\(chars.last!)"
        return result
    }
    
    var body: some View {
        TopBarView(title:"Pixel Game", color: .gameGreen)
        VStack(spacing: 20) {
            Text("🔴 Data Compression Challenge")
                .font(.title)
            
            Text("Original Pixels: \(inputString)")
                .font(.headline)
            
            Button("Compress") {
                compressedString = runLengthEncoding(inputString)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Compressed Data: \(compressedString)")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding()
    }
}
#Preview {
    PixelGameView()
}
