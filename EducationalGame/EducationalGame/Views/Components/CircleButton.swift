import SwiftUI

struct CircleButton: View {
    var iconName: String
    var color: Color
    @Environment(\.currentView) var currentView
    @Environment(\.currentPhase) var currentPhase
    @State private var showInfoAlert = false
    @State private var viewModel: CircleButtonViewModel
    
    init(iconName: String, color: Color) {
        self.iconName = iconName
        self.color = color
        // Initialize with empty values, will be updated when environment values change
        _viewModel = State(initialValue: CircleButtonViewModel())
    }

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
        .alert(isPresented: $showInfoAlert) {
            Alert(
                title: Text(viewModel.getInfoTitle()),
                message: Text(viewModel.getInfoMessage()),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: currentView) { _, newValue in
            viewModel.currentView = newValue
        }
        .onChange(of: currentPhase) { _, newValue in
            viewModel.currentPhase = newValue
        }
    }

    private func handleAction() {
        switch iconName {
        case "gear":
            navigateTo(SettingsView())
        case "arrow.left":
            navigateTo(ContentView())
        case "info.circle":
            // Update viewModel with current values before showing alert
            viewModel.currentView = currentView
            viewModel.currentPhase = currentPhase
            showInfoAlert = true
        case "trophy.circle.fill":
            navigateTo(ContentView())
        default:
            break
        }
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CircleButton(iconName: "info.circle", color: .blue)
                .environment(\.currentView, "BinaryGame")
                .environment(\.currentPhase, .intro)
            
            CircleButton(iconName: "info.circle", color: .blue)
                .environment(\.currentView, "PixelGame")
                .environment(\.currentPhase, .challenges)
        }
    }
}
