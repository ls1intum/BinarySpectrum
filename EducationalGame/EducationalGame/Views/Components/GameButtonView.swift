import SwiftUI

struct GameButtonView: View {
    let color: Color
    let icon: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.black)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
        }
        .frame(width: 320, height: 240)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 5)
    }
}

#Preview {
    GameButtonView(color: .blue, icon: "plus", title: "Add")
}
