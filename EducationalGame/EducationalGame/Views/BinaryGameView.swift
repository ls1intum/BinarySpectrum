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
                Questions(viewModel: viewModel)
            case .exploration:
                Text("BinaryLearningGame(viewModel: viewModel)")
            case .challenges:
                BinaryLearningGame(viewModel: viewModel)
            case .reward:
                Text("Congratulations")
            }
        }
    }
}

struct Questions: View {
    @State var viewModel: BinaryGameViewModel
    var body: some View {
        QuestionsView(questions: viewModel.introQuestions, currentPhase: $viewModel.currentPhase)
    }
}

struct BinaryLearningGame: View {
    @State var viewModel: BinaryGameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: viewModel.instructionText == "" ? LocalizedStringResource("Tap the circles to toggle between 0 and 1. Your goal is to represent \(viewModel.targetNumber) in binary.") : viewModel.instructionText)
            Spacer()
            
            HStack(spacing: 16) {
                ForEach(0..<viewModel.digitCount, id: \.self) { index in
                    VStack {
                        Text("\(Int(pow(2.0, Double(viewModel.digitCount - 1 - index))))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            withAnimation {
                                viewModel.binaryDigits[index] = (viewModel.binaryDigits[index] == "0") ? "1" : "0"
                            }
                        }) {
                            Text(viewModel.binaryDigits[index])
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 50, height: 50)
                                .background(viewModel.binaryDigits[index] == "1" ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                        }
                    }
                }
            }
            
            Text("\(viewModel.decimalValue)")
                .font(GameTheme.bodyFont)
                .frame(width: 80, height: 80)
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(12)
            
            Spacer()
            
            Button(action: {
                viewModel.checkAnswer()
            }) {
                Text("Check Answer")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            if viewModel.showHint {
                Text("✅ Great job! \(viewModel.targetNumber) in binary is \(String(viewModel.targetNumber, radix: 2))")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .padding()
    }
}
#Preview {
    BinaryGameView()
}
