import SwiftUI

struct CircleButton: View {
    var iconName: String
    var color: Color
    @Environment(\.currentView) var currentView
    @Environment(\.currentPhase) var currentPhase
    @State private var showInfoAlert = false
    @State private var showInfoPopup = false
    @State private var viewModel: CircleButtonViewModel
    @EnvironmentObject private var navigationState: NavigationState
    
    init(iconName: String, color: Color) {
        self.iconName = iconName
        self.color = color
        // Initialize with empty values, will be updated when environment values change
        _viewModel = State(initialValue: CircleButtonViewModel())
    }

    var body: some View {
        ZStack {
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
            
            if showInfoPopup {
                InfoPopup(
                    title: viewModel.getInfoTitle(),
                    message: viewModel.getInfoMessage(),
                    buttonTitle: "OK",
                    onButtonTap: {
                        showInfoPopup = false
                    }
                )
            }
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
            withAnimation(.easeInOut(duration: 0.3)) {
                navigationState.path.append("settings")
            }
        case "arrow.left":
            withAnimation(.easeInOut(duration: 0.3)) {
                // Go back or to root if we can't go back
                if navigationState.path.count > 0 {
                    navigationState.path.removeLast()
                } else {
                    navigationState.path = NavigationPath()
                }
            }
        case "info.circle":
            // Update viewModel with current values before showing popup
            viewModel.currentView = currentView
            viewModel.currentPhase = currentPhase
            showInfoPopup = true
        case "trophy.circle.fill":
            withAnimation(.easeInOut(duration: 0.3)) {
                navigationState.path = NavigationPath() // Go to root
            }
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
                .environmentObject(NavigationState())
            
            CircleButton(iconName: "info.circle", color: .blue)
                .environment(\.currentView, "PixelGame")
                .environment(\.currentPhase, .challenges)
                .environmentObject(NavigationState())
        }
    }
}
