import SwiftUI

struct BinaryGameView: View {
    @State private var viewModel: BinaryGameViewModel
    
    init(viewModel: BinaryGameViewModel = BinaryGameViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[0].name, color: GameConstants.miniGames[0].color)
            
            switch viewModel.currentPhase {
            case .intro:
                DialogueView(
                    personaImage: GameConstants.miniGames[0].personaImage,
                    dialogues: viewModel.introDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .questions:
                Questions(viewModel: viewModel)
            case .exploration:
                BinaryExplorationView(viewModel: viewModel)
            case .challenges:
                BinaryLearningGame(viewModel: viewModel)
            case .reward:
                Text("Congratulations")
            case .tutorial:
                Text("TODO")
            case .practice:
                Text("TODO")
            case .advancedChallenges:
                Text("TODO")
            case .finalChallenge:
                Text("TODO")
            case .review:
                Text("TODO")
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

struct BinaryExplorationView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var selectedNumber: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Explore how numbers are represented in binary!")
            Spacer()
            
            VStack(spacing: 15) {
                Text("Select a number to see its binary representation")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                HStack(spacing: 10) {
                    ForEach(0..<8) { number in
                        Button(action: {
                            selectedNumber = number
                        }) {
                            Text("\(number)")
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 40, height: 40)
                                .background(selectedNumber == number ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gameGray.opacity(0.1))
            .cornerRadius(15)

            Spacer()
            
            VStack(spacing: 15) {
                Text("Binary Representation")
                    .font(.title2)
                    .bold()
                    
                let binaryString = String(selectedNumber, radix: 2).paddingLeft(with: "0", toLength: 3)
                let binaryDigits = binaryString.map { String($0) }
                    
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        HStack(spacing: 8) {
                            VStack {
                                Text("\(Int(pow(2.0, Double(2 - index))))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    
                                Text(binaryDigits[index])
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(width: 50, height: 50)
                                    .background(Color.gameRed.opacity(0.8))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                                
                            let power = Int(pow(2.0, Double(2 - index)))
                            let digit = Int(binaryDigits[index]) ?? 0
                            VStack {
                                Text("\(digit) × \(power) =")
                                    .font(.system(size: 18, weight: .medium))
                                Text("\(digit * power)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.gameRed)
                            }
                        }
                    }
                }
                    
                Text("\(selectedNumber) in binary is \(binaryString)")
                    .font(.headline)
                    .padding(.top, 10)
                    
                Text("Total: \(binaryDigits.enumerated().map { Int(String($0.element))! * Int(pow(2.0, Double(2 - $0.offset))) }.reduce(0, +))")
                    .font(.headline)
                    .bold()
                    .padding(.top, 5)
            }
            .padding()
            .background(Color.gameGray.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: .gameLightBlue,
                        action: {
                            viewModel.currentPhase.next()
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
    }
}

#Preview("Intro Phase") {
    let viewModel = BinaryGameViewModel()
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Questions Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .questions
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Exploration Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .exploration
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Challenges Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .challenges
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Reward Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .reward
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Tutorial Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .tutorial
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Practice Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .practice
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Advanced Challenges Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .advancedChallenges
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Final Challenge Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .finalChallenge
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Review Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .review
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
