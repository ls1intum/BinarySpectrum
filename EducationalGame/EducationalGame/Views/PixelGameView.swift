import SwiftUI

struct PixelGameView: View {
    @State private var viewModel = PixelGameViewModel()
    
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[1].name, color: GameConstants.miniGames[1].color)
            
            switch viewModel.currentPhase {
            case .intro:
                DialogueView(
                    characterIcon: "square.grid.3x3.fill",
                    dialogues: viewModel.introDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .questions:
                PixelGameQuestions(viewModel: viewModel)
            case .exploration:
                Text("TODO")
            case .challenges:
                PixelGameChallenge(viewModel: viewModel)
            case .reward:
                RewardView(
                    message: "Congratulations! You've completed the Pixel Decoder challenge!",
                    onContinue: { viewModel.resetGame() }
                )
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

// MARK: - Questions View
struct PixelGameQuestions: View {
    @State var viewModel: PixelGameViewModel
    
    var body: some View {
        QuestionsView(questions: viewModel.introQuestions, currentPhase: $viewModel.currentPhase)
    }
}

// MARK: - Main Game Challenge
struct PixelGameChallenge: View {
    @ObservedObject var viewModel: PixelGameViewModel
    
    var body: some View {
        VStack {
            InstructionBar(text: "Decode the image. Remember: if a pixel is 1, turn it black. If it's 0, leave it white. Selecting wrong pixels decreases progress!")
            Spacer()
            
            HStack {
                Spacer()
                
                // Game Grid
                ZStack {
                    Color.gray.opacity(0.2)
                        .cornerRadius(10)
                        .padding(2)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.cellSize)), count: viewModel.gridSize), spacing: 2) {
                        ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                            Rectangle()
                                .fill(viewModel.blackCells.contains(index) ? Color.black : Color.white)
                                .frame(width: viewModel.cellSize, height: viewModel.cellSize)
                                .border(Color.gray, width: 1)
                                .onTapGesture {
                                    viewModel.toggleCell(index)
                                }
                        }
                    }
                    .padding(0)
                }
                .frame(width: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2,
                       height: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2)
                
                Spacer()
                
                VStack {
                    // Binary Code Display
                    Text(viewModel.formattedCode)
                        .font(.headline)
                        .padding()
                        .background(Color.gamePurple.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 8)
                    
                    // Progress Bar
                    VStack(alignment: .leading) {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ProgressView(value: viewModel.progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .accentColor(.blue)
                            .padding(.bottom)
                    }
                    
                    // Check Answer Button
                    Button(action: {
                        viewModel.checkAnswer()
                    }) {
                        Text("Check Answer")
                            .font(.headline)
                            .padding()
                            .frame(width: 160)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding()
                    .opacity(viewModel.hintShown ? 0.6 : 1.0)
                    .disabled(viewModel.hintShown)
                }
                .frame(width: 200)
                
                Spacer()
            }
            .padding()
            
            if viewModel.hintShown {
                Text(viewModel.hintMessage)
                    .font(.headline)
                    .foregroundColor(viewModel.isCorrect ? .green : .orange)
                    .padding()
                    .multilineTextAlignment(.center)
                
                if viewModel.isCorrect {
                    Button(action: {
                        viewModel.currentPhase = .reward
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .padding()
                            .frame(width: 160)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        viewModel.hideHint()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .padding()
                            .frame(width: 160)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Reward View
struct RewardView: View {
    var message: String
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
                .shadow(radius: 10)
            
            Text(message)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}
#Preview {
    PixelGameView()
}
