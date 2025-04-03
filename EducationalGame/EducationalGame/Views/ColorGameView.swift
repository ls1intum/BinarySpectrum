import SwiftUI

struct ColorGameView: View {
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[2].name, color: GameConstants.miniGames[2].color)
            Spacer()
            InstructionBar(text: "Try out mixing the Red, Green and Blue values to make a color")
            Spacer()
            RGBColorPickerView()
            Spacer()
        }
    }
}

struct RGBColorPickerView: View {
    @State private var red: Double = 0.93
    @State private var green: Double = 0.39
    @State private var blue: Double = 0.86
    
    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 16) {
                ColorSlider(value: $red, color: .red)
                ColorSlider(value: $green, color: .green)
                ColorSlider(value: $blue, color: .blue)
            }
            
            VStack {
                Circle()
                    .fill(Color(red: red, green: green, blue: blue))
                    .frame(width: 100, height: 100)
                    .shadow(radius: 5)
                
                Text(hexCode)
                    .font(.headline)
                    .padding()
                    .background(Color(red: 1, green: 0.6, blue: 0.6))
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
    
    private var hexCode: String {
        String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Slider(value: $value, in: 0...1)
                .frame(width: 400)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


#Preview {
    ColorGameView()
}
