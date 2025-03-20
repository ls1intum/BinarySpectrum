import SwiftUI

struct CircleButton: View { // TODO: create view model?
    var iconName: String
    var color: Color
    // var currentView: String // Helps determine the info message
    // @State private var showInfoAlert = false

    var body: some View {
        Button(action: handleAction) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.7))
                    .frame(width: 90, height: 90)
                    .shadow(radius: 5)

                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
        /*
         .alert(isPresented: $showInfoAlert) {
             Alert(
                 title: Text("Information"),
                 message: Text(getInfoMessage()),
                 dismissButton: .default(Text("OK"))
             )
         }
          */
    }

    private func handleAction() {
        switch iconName {
        case "gear":
            navigateTo(SettingsView())
        case "arrow.left":
            navigateTo(ContentView())
        // case "info.circle":
        // showInfoAlert = true
        default:
            break
        }
    }

    /*
     private func getInfoMessage() -> String {
         switch currentView {
         case "BinaryGame":
             return "In the Binary Game, you will learn how to represent numbers using binary digits."
         case "PixelGame":
             return "The Pixel Game teaches you about digital images and how pixels work."
         case "ColorGame":
             return "The Color Game helps you understand color mixing and visual perception."
         default:
             return "This is an educational game designed to make learning fun!"
         }
     }
     */
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton(iconName: "star.fill", color: .blue)
    }
}
