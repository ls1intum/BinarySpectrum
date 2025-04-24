import SwiftUI

struct PixelGameView: View {
    @State private var viewModel: PixelGameViewModel
    
    init(viewModel: PixelGameViewModel = PixelGameViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[1].name, color: GameConstants.miniGames[1].color)
            
            switch viewModel.currentPhase {
            case .intro:
                DialogueView(
                    personaImage: GameConstants.miniGames[1].personaImage,
                    color: GameConstants.miniGames[1].color,
                    dialogues: viewModel.introDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .questions:
                PixelGameQuestions(viewModel: viewModel)
            case .exploration:
                PixelGameExploration(viewModel: viewModel)
            case .challenges:
                PixelGameChallenge(viewModel: viewModel)
            case .tutorial:
                DialogueView(
                    personaImage: GameConstants.miniGames[1].personaImage,
                    color: GameConstants.miniGames[1].color,
                    dialogues: viewModel.rleDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .practice:
                PixelGameBinaryEncoding(viewModel: viewModel)
            case .advancedChallenges:
                PixelGameRLEChallenge(viewModel: viewModel)
            case .finalChallenge:
                Text("TODO")
            case .review:
                ReviewView(
                    title: "Binary Images",
                    items: viewModel.reviewCards.map { card in
                        ReviewItem(
                            title: card.title,
                            content: card.content,
                            example: card.example
                        )
                    },
                    color: GameConstants.miniGames[1].color,
                    onCompletion: {
                        viewModel.completeGame(score: 50, percentage: 1.0)
                    }
                )
            case .reward:
                RewardView(
                    message: "Incredible achievement! You've mastered binary images and Run-Length Encoding! You now understand how computers store images efficiently, from simple black-and-white patterns to complex pixel art. This knowledge is the foundation of image compression and digital graphics. You're well on your way to becoming a true computer scientist!",
                    personaImage: GameConstants.miniGames[1].personaImage,
                    badgeTitle: GameConstants.miniGames[1].achievementName,
                    color: GameConstants.miniGames[1].color
                )
            }
        }
    }
}

// MARK: - Questions View

struct PixelGameQuestions: View {
    @State var viewModel: PixelGameViewModel
    
    var body: some View {
        QuestionsView(questions: viewModel.introQuestions,
                      currentPhase: $viewModel.currentPhase, color: GameConstants.miniGames[1].color)
    }
}

// MARK: - Main Game Challenge

struct PixelGameChallenge: View {
    @ObservedObject var viewModel: PixelGameViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                InstructionBar(text: "Decode the image. Remember: if a pixel is 1, turn it black. If it's 0, leave it white. Selecting wrong pixels decreases progress!")
                Spacer()
            
                HStack {
                    Spacer()
                
                    // Game Grid
                    ZStack {
                        Color.gray.opacity(0.2)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.cellSize)), count: viewModel.gridSize), spacing: 2) {
                            ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(viewModel.blackCells.contains(index) ? Color.black : Color.white)
                                        .frame(width: viewModel.cellSize, height: viewModel.cellSize)
                                        .border(Color.gray.opacity(0.3), width: 1)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                
                                    if viewModel.blackCells.contains(index) {
                                        Text("1")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("0")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.toggleCell(index)
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }
                    .frame(width: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16,
                           height: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16)
                
                    Spacer()
                
                    VStack(spacing: 20) {
                        // Binary Code Display
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Binary Code")
                                .font(.headline)
                                .foregroundColor(.gray)
                        
                            Text(viewModel.formattedCode)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gamePurple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gamePurple.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                        // Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress")
                                .font(.headline)
                                .foregroundColor(.gray)
                        
                            ProgressView(value: viewModel.progress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                .padding(.bottom)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .frame(width: 200)
                
                    Spacer()
                }
                .padding()
            
                if viewModel.hintShown {
                    VStack(spacing: 16) {
                        Text(viewModel.hintMessage)
                            .font(.headline)
                            .foregroundColor(viewModel.isCorrect ? .green : .orange)
                            .padding()
                            .multilineTextAlignment(.center)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                        if viewModel.isCorrect {
                            Button(action: {
                                viewModel.completeGame(score: 100, percentage: viewModel.progress)
                            }) {
                                Text("Continue")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 160)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
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
                                    .shadow(radius: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding()
                }
            
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // Check Answer Button
                    AnimatedCircleButton(
                        iconName: "checkmark.circle.fill",
                        color: GameConstants.miniGames[1].color,
                        action: {
                            viewModel.checkAnswer()
                        }
                    )
                    .opacity(viewModel.hintShown ? 0.6 : 1.0)
                    .disabled(viewModel.hintShown)
                    .padding()
                }
            }
        }
    }
}

// MARK: - Exploration View

struct PixelGameExploration: View {
    @ObservedObject var viewModel: PixelGameViewModel
    @State private var isAnimating = false
    // Custom grid size for exploration phase
    private let explorationGridSize = 16
    private let explorationCellSize: CGFloat = 25
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                InstructionBar(text: "Explore the grid! Click pixels to toggle them between black and white, and see how the binary code changes.")
                Spacer()
            
                HStack {
                    // Game Grid
                    ZStack {
                        Color.gray.opacity(0.2)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(explorationCellSize), spacing: 2), count: explorationGridSize), spacing: 2) {
                            ForEach(0..<(explorationGridSize * explorationGridSize), id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .fill(viewModel.blackCells.contains(index) ? Color.black : Color.white)
                                        .frame(width: explorationCellSize, height: explorationCellSize)
                                        .border(Color.gray.opacity(0.3), width: 1)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                
                                    if viewModel.blackCells.contains(index) {
                                        Text("1")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("0")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.toggleCell(index)
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }
                    .frame(width: CGFloat(explorationGridSize) * explorationCellSize + CGFloat(explorationGridSize - 1) * 2 + 16,
                           height: CGFloat(explorationGridSize) * explorationCellSize + CGFloat(explorationGridSize - 1) * 2 + 16)
                }
                .padding()
            
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: GameConstants.miniGames[1].color,
                        action: {
                            viewModel.completeGame(score: 50, percentage: 1.0)
                        }
                    )
                    .padding()
                }
            }
        }
    }
}

// MARK: - Exploration View

struct PixelGameBinaryEncoding: View {
    @ObservedObject var viewModel: PixelGameViewModel
    
    var body: some View {
        VStack {
            InstructionBar(text: "Now it's your turn! Write the binary code for this image. Remember: 1 for black pixels, 0 for white pixels, and 8 bits per row!")
            Spacer()
            
            HStack {
                Spacer()
                
                // Challenge Grid
                ZStack {
                    Color.gray.opacity(0.2)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.cellSize)), count: viewModel.gridSize), spacing: 2) {
                        ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                            ZStack {
                                Rectangle()
                                    .fill(viewModel.encodingChallengeGrid.contains(index) ? Color.black : Color.white)
                                    .frame(width: viewModel.cellSize, height: viewModel.cellSize)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(width: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16,
                       height: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16)
                
                Spacer()
                
                // Binary Code Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Binary Code")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $viewModel.playerBinaryCode)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(width: 200, height: 200)
                        .background(Color.gamePurple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gamePurple.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AnimatedCircleButton(
                        iconName: "checkmark.circle.fill",
                        color: GameConstants.miniGames[1].color,
                        action: {
                            viewModel.checkBinaryEncoding()
                        }
                    )
                    .opacity(viewModel.hintShown ? 0.6 : 1.0)
                    .disabled(viewModel.hintShown)
                    .padding()
                }
            }
            
            if viewModel.hintShown {
                VStack(spacing: 16) {
                    Text(viewModel.hintMessage)
                        .font(.headline)
                        .foregroundColor(viewModel.isCorrect ? .green : .orange)
                        .padding()
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    if viewModel.isCorrect {
                        Button(action: {
                            viewModel.completeGame(score: 150, percentage: 1.0)
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .padding()
                                .frame(width: 160)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
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
                                .shadow(radius: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - RLE Challenge View

struct PixelGameRLEChallenge: View {
    @ObservedObject var viewModel: PixelGameViewModel
    
    var body: some View {
        VStack {
            InstructionBar(text: "Decode the image using Run-Length Encoding. W means white pixels, B means black pixels, and the number tells you how many!")
            Spacer()
            
            HStack {
                Spacer()
                
                // RLE Code Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("RLE Code")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.rleCode.components(separatedBy: "\n"), id: \.self) { line in
                            Text(line)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.gamePurple.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gamePurple.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                // Game Grid
                ZStack {
                    Color.gray.opacity(0.2)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.cellSize)), count: viewModel.gridSize), spacing: 2) {
                        ForEach(0..<(viewModel.gridSize * viewModel.gridSize), id: \.self) { index in
                            ZStack {
                                Rectangle()
                                    .fill(viewModel.blackCells.contains(index) ? Color.black : Color.white)
                                    .frame(width: viewModel.cellSize, height: viewModel.cellSize)
                                    .border(Color.gray.opacity(0.3), width: 1)
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.toggleCell(index)
                                }
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(width: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16,
                       height: CGFloat(viewModel.gridSize) * viewModel.cellSize + CGFloat(viewModel.gridSize - 1) * 2 + 16)
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AnimatedCircleButton(
                        iconName: "checkmark.circle.fill",
                        color: GameConstants.miniGames[1].color,
                        action: {
                            viewModel.checkRLEAnswer()
                        }
                    )
                    .opacity(viewModel.hintShown ? 0.6 : 1.0)
                    .disabled(viewModel.hintShown)
                    .padding()
                }
            }
            
            if viewModel.hintShown {
                VStack(spacing: 16) {
                    Text(viewModel.hintMessage)
                        .font(.headline)
                        .foregroundColor(viewModel.isCorrect ? .green : .orange)
                        .padding()
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    if viewModel.isCorrect {
                        Button(action: {
                            viewModel.completeGame(score: 200, percentage: 1.0)
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .padding()
                                .frame(width: 160)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
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
                                .shadow(radius: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

// Button Style for Scale Animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview("Intro Phase") {
    let viewModel = PixelGameViewModel()
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Questions Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .questions
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Exploration Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .exploration
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Challenges Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .challenges
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Reward Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .reward
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Tutorial Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .tutorial
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Practice Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .practice
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Advanced Challenges Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .advancedChallenges
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Final Challenge Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .finalChallenge
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Review Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .review
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
