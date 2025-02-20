import SwiftUI

struct ColorGameView: View {
    @State private var redValue: Double = 0
    @State private var greenValue: Double = 0
    @State private var blueValue: Double = 0
    
    func getHexColor() -> String {
        let r = Int(redValue * 255)
        let g = Int(greenValue * 255)
        let b = Int(blueValue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    var body: some View {
        TopBarView(title: "Colors Game", color: .gameBlue)
        VStack(spacing: 20) {
            Text("🎨 RGB Color Encoder")
                .font(.title)
            
            Color(red: redValue, green: greenValue, blue: blueValue)
                .frame(width: 150, height: 150)
                .border(Color.black, width: 2)
            
            VStack {
                Text("Red: \(Int(redValue * 255))")
                Slider(value: $redValue, in: 0...1)
                    .accentColor(.red)
            }
            
            VStack {
                Text("Green: \(Int(greenValue * 255))")
                Slider(value: $greenValue, in: 0...1)
                    .accentColor(.green)
            }
            
            VStack {
                Text("Blue: \(Int(blueValue * 255))")
                Slider(value: $blueValue, in: 0...1)
                    .accentColor(.blue)
            }
            
            Text("Hex Code: \(getHexColor())")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    ColorGameView()
}
