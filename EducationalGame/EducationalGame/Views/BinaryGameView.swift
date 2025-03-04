import SwiftUI

struct BinaryGameView: View {
    @State private var viewModel = BinaryGameViewModel()

    var body: some View {
        VStack {
            TopBarView(title: "Binary Game", color: .gameRed)

            switch viewModel.currentPhase {
                case .intro:
                    DialogueView(
                        characterIcon: "lizard.fill",
                        dialogues: viewModel.introDialogue,
                        currentPhase: $viewModel.currentPhase
                    )
                case .questions:
                    Phase1()
                case .challenges:
                    Phase1()
                case .reward:
                    Phase1()
            }
        }
    }
}

struct Phase1: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

#Preview {
    BinaryGameView()
}
