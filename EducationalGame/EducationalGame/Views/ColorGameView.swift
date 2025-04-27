import SwiftUI

struct ColorGameView: View {
    @State private var viewModel: ColorGameViewModel
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(viewModel: ColorGameViewModel = ColorGameViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            VStack {
                // Top spacing to accommodate the TopBarView
                Spacer().frame(height: 90)
                
                // Game content based on phase
                switch viewModel.currentPhase {
                case .intro:
                    DialogueView(
                        personaImage: GameConstants.miniGames[2].personaImage,
                        color: GameConstants.miniGames[2].color,
                        dialogues: viewModel.introDialogue,
                        gameType: viewModel.gameType,
                        currentPhase: $viewModel.currentPhase
                    )
                case .questions:
                    QuestionsView(
                        questions: viewModel.introQuestions,
                        currentPhase: $viewModel.currentPhase,
                        color: GameConstants.miniGames[2].color,
                        gameType: viewModel.gameType
                    )
                case .exploration:
                    ColorExploration(viewModel: viewModel)
                case .tutorial:
                    DialogueView(
                        personaImage: GameConstants.miniGames[2].personaImage,
                        color: GameConstants.miniGames[2].color,
                        dialogues: viewModel.hexLearningDialogue,
                        gameType: viewModel.gameType,
                        currentPhase: $viewModel.currentPhase
                    )
                case .practice:
                    ColorHexChallenge(viewModel: viewModel)
                case .challenges:
                    DialogueView(
                        personaImage: GameConstants.miniGames[2].personaImage,
                        color: GameConstants.miniGames[2].color,
                        dialogues: viewModel.opacityLearningDialogue,
                        gameType: viewModel.gameType,
                        currentPhase: $viewModel.currentPhase
                    )
                case .advancedChallenges:
                    OpacityChallenge(viewModel: viewModel)
                case .finalChallenge:
                    ColorAlphaChallenge(viewModel: viewModel)
                case .review:
                    ReviewView(
                        title: "Digital Colors",
                        items: viewModel.reviewCards.map { card in
                            ReviewItem(
                                title: card.title,
                                content: card.content,
                                example: card.example
                            )
                        },
                        color: GameConstants.miniGames[2].color,
                        onCompletion: {
                            viewModel.completeGame(score: 50, percentage: 1.0)
                        }
                    )
                case .reward:
                    RewardView(miniGameIndex: 2, message: viewModel.rewardMessage)
                        .environmentObject(navigationState)
                        .environmentObject(userViewModel)
                }
            }
            
            // TopBarView overlay at the top
            TopBar(title: GameConstants.miniGames[2].name, color: GameConstants.miniGames[2].color)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct ColorExploration: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                InstructionBar(text: "Change the RGB colors to make your favorite color")
            
                Circle()
                    .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue))
                    .frame(width: 150, height: 150)
                    .shadow(radius: 5)
            
                Text(viewModel.currentColorHex)
                    .font(.title)
                    .padding(8)
                    .background(Color.gameGray)
                    .cornerRadius(8)
            
                VStack(spacing: 20) {
                    ColorSlider(value: $viewModel.red, color: .red)
                    ColorSlider(value: $viewModel.green, color: .green)
                    ColorSlider(value: $viewModel.blue, color: .blue)
                }
                .padding(.horizontal, 50)

                // Next Button at the Bottom Right
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: GameConstants.miniGames[2].color,
                        action: {
                            // Complete exploration and advance
                            viewModel.completeGame(score: 50, percentage: 1.0)
                        }
                    )
                    .padding()
                }
            }
        }
    }
}

struct ColorHexChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                InstructionBar(text: "Match the target color using the RGB sliders!")
                
                HStack(spacing: 60) {
                    // Target Color
                    VStack {
                        Text("Target Color")
                            .font(GameTheme.subheadingFont)
                        Circle()
                            .fill(viewModel.targetColor)
                            .frame(width: 150, height: 150)
                            .shadow(radius: 5)
                        Text(viewModel.targetColorHex)
                            .font(.headline)
                            .padding(8)
                            .background(Color.gameGray)
                            .cornerRadius(8)
                    }
                
                    // Current Color
                    VStack {
                        Text("Your Color")
                            .font(GameTheme.subheadingFont)
                        Circle()
                            .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue))
                            .frame(width: 150, height: 150)
                            .shadow(radius: 5)
                        Text("") // empty text to align both colors
                            .font(.headline)
                            .padding(8)
                            .cornerRadius(8)
                    }
                }
            
                VStack(spacing: 20) {
                    ColorSlider(value: $viewModel.red, color: .red)
                    ColorSlider(value: $viewModel.green, color: .green)
                    ColorSlider(value: $viewModel.blue, color: .blue)
                }
                .padding(.horizontal, 50)
            }
            ColorGameControls(viewModel: viewModel)
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: false)
        }
    }
}

struct OpacityChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                InstructionBar(text: "Match both the color and opacity of the target")
            
                HStack(spacing: 60) {
                    // Target Color
                    VStack {
                        Text("Target Color")
                            .font(GameTheme.subheadingFont)
                        ZStack {
                            CheckerboardBackground()
                            Circle()
                                .fill(viewModel.targetColor.opacity(viewModel.targetAlpha))
                                .frame(width: 150, height: 150)
                        }
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        Text(viewModel.targetColorHex)
                            .font(.headline)
                            .padding(8)
                            .background(Color.gameGray)
                            .cornerRadius(8)
                    }
                
                    // Current Color
                    VStack {
                        Text("Your Color")
                            .font(GameTheme.subheadingFont)
                        ZStack {
                            CheckerboardBackground()
                            Circle()
                                .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue)
                                    .opacity(viewModel.alpha))
                                .frame(width: 150, height: 150)
                        }
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        Text(viewModel.currentColorHex)
                            .font(.headline)
                            .padding(8)
                            .background(Color.gameGray)
                            .cornerRadius(8)
                    }
                }
            
                VStack(spacing: 20) {
                    ColorSlider(value: $viewModel.red, color: .red)
                    ColorSlider(value: $viewModel.green, color: .green)
                    ColorSlider(value: $viewModel.blue, color: .blue)
                    ColorSlider(value: $viewModel.alpha, color: .gray)
                }
                .padding(.horizontal, 50)
            }
            ColorGameControls(viewModel: viewModel)
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: true)
        }
    }
}

struct ColorAlphaChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Adjust the opacity to reveal the hidden message!")
            
            HStack(alignment: .top, spacing: 30) {
                // Volume control circle
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.6))
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 50, height: 50)
                            .offset(x: 35, y: -35)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let height = 200.0
                                let touchY = value.location.y
                                viewModel.opacityValue = max(0, min(1, touchY / height))
                                rotationAngle = viewModel.opacityValue * 180 // Reduced rotation range
                            }
                    )
                }
                
                // Grid of squares
                VStack {
                    VStack(spacing: 2) {
                        ForEach(0..<min(viewModel.alphaGrid.count, 4), id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<min(viewModel.alphaGrid[row].count, 4), id: \.self) { col in
                                    let square = viewModel.alphaGrid[row][col]
                                    let squareOpacity = square.baseAlpha * (square.increasesOpacity ? viewModel.opacityValue : (1 - viewModel.opacityValue))
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.blue.opacity(squareOpacity))
                                            .frame(width: 60, height: 60)
                                        
                                        if !square.letter.isEmpty {
                                            Text(square.letter)
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.blue.opacity(0.8)) // Fixed opacity for letters
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            // Answer field
            HStack(spacing: 12) {
                TextField("Enter your answer", text: $viewModel.userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .padding(.horizontal, 50)
                    .multilineTextAlignment(.center)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                
                Button("Check Answer") {
                    viewModel.checkAlphaAnswer()
                }
                .font(.title3)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if viewModel.showAlphaSuccess {
                    VStack {
                        Text("Correct! Well done! 🎉")
                            .font(.title2)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                            .padding()
                        
                        Button("Continue") {
                            viewModel.completeGame(score: 200, percentage: 1.0)
                        }
                        .font(.title3)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.generateNewAlphaGrid()
        }
    }
}

struct ColorFinalChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: "Final Challenge: Match the target color with limited attempts!")
            
            // Same as ColorAlphaChallenge but with attempt counter
            ColorAlphaChallenge(viewModel: viewModel)
            
            Text("Attempts remaining: \(viewModel.attemptsRemaining)")
                .font(.headline)
                .foregroundColor(viewModel.attemptsRemaining < 3 ? .red : .primary)
        }
    }
}

struct ColorGameControls: View {
    @ObservedObject var viewModel: ColorGameViewModel
    @State private var showAlert = false
    @State private var showPopup = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AnimatedCircleButton(
                        iconName: "checkmark.circle.fill",
                        color: GameConstants.miniGames[2].color,
                        action: {
                            viewModel.checkColorMatch()
                            showPopup = true
                        }
                    )
                    .padding()
                }
            }
            
            if showPopup {
                if viewModel.isCorrect {
                    InfoPopup(
                        title: "Correct!",
                        message: viewModel.hintMessage,
                        buttonTitle: "Continue",
                        onButtonTap: {
                            showPopup = false
                            viewModel.completeGame(score: 100, percentage: 1.0)
                        }
                    )
                } else {
                    InfoPopup(
                        title: "Try Again",
                        message: viewModel.hintMessage,
                        buttonTitle: "OK",
                        onButtonTap: {
                            showPopup = false
                            viewModel.hideHint()
                        }
                    )
                }
            }
        }
    }
}

struct CheckerboardBackground: View {
    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 10
            let rows = Int(size.height / tileSize)
            let columns = Int(size.width / tileSize)
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let rect = CGRect(x: CGFloat(col) * tileSize,
                                      y: CGFloat(row) * tileSize,
                                      width: tileSize,
                                      height: tileSize)
                    
                    context.fill(Path(rect), with: .color((row + col).isMultiple(of: 2) ? .white : .gray.opacity(0.3)))
                }
            }
        }
        .frame(width: 150, height: 150)
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
            
            Slider(value: $value)
                .accentColor(color)
                .frame(width: 400)
            
            Text(String(format: "%.0f", value * 255))
                .frame(width: 40)
                .font(.headline)
        }
        .padding()
        .background(Color.gameGray.opacity(0.3))
        .cornerRadius(15)
    }
}

#Preview("Intro Phase") {
    let viewModel = ColorGameViewModel()
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Exploration Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .exploration
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Color match") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .practice
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Opacity match") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .practice
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Advanced Challenges Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .advancedChallenges
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Final Challenge Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .finalChallenge
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Review Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .review
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Reward Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .reward
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
