import SwiftUI

struct ColorGameView: View {
    @Bindable var viewModel: ColorGameViewModel
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var userViewModel: UserViewModel
    
    init(viewModel: ColorGameViewModel = ColorGameViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        BaseGameView {
            ZStack(alignment: .top) {
                VStack {
                    Spacer().frame(height: 90)
                    currentPhaseView
                }
                
                TopBar(title: GameConstants.miniGames[2].name, color: GameConstants.miniGames[2].color)
                
                if viewModel.showHint {
                    InfoPopup(
                        title: viewModel.isCorrect ? "Correct!" : "Try Again",
                        message: viewModel.hintMessage,
                        buttonTitle: viewModel.isCorrect ? "Continue" : "OK",
                        onButtonTap: {
                            viewModel.hideHint()
                        }
                    )
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(10)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                // Configure challenge parameters if any
                if let challengeParams = navigationState.challengeParams {
                    viewModel.configureWithChallengeParams(challengeParams)
                }
            }
        }
        .environmentObject(navigationState)
        .environmentObject(userViewModel)
    }
    
    @ViewBuilder
    private var currentPhaseView: some View {
        switch viewModel.currentPhase {
        case .introDialogue, .tutorialDialogue, .lastDialogue:
            DialogueView(
                personaImage: GameConstants.miniGames[2].personaImage,
                color: GameConstants.miniGames[2].color,
                dialogues: dialogueContent,
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
            ColorExplorationView(viewModel: viewModel)
        case .noviceChallenge:
            ColorHexChallengeView(viewModel: viewModel)
        case .apprenticeChallenge:
            OpacityChallengeView(viewModel: viewModel)
        case .adeptChallenge:
            ReversedChallengeView(viewModel: viewModel)
        case .expertChallenge:
            ColorAlphaChallengeView(viewModel: viewModel)
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
    
    private var dialogueContent: [LocalizedStringResource] {
        switch viewModel.currentPhase {
        case .introDialogue: return viewModel.introDialogue
        case .tutorialDialogue: return viewModel.hexLearningDialogue
        case .lastDialogue: return viewModel.opacityLearningDialogue
        default: return []
        }
    }
}

// MARK: - Challenge Views

struct ColorExplorationView: View {
    @Bindable var viewModel: ColorGameViewModel
    
    var body: some View {
        BaseGameView(
            instruction: "Change the red, green and blue intensity to make your favorite color",
            showCheckButton: true,
            onCheck: { viewModel.nextPhase() },
            gameColor: GameConstants.miniGames[2].color
        ) {
            VStack(spacing: 30) {
                ColorPreviewView(
                    color: viewModel.currentColor.color,
                    hexString: viewModel.currentColor.hexString
                )
                
                ColorSlidersView(
                    red: $viewModel.currentColor.red,
                    green: $viewModel.currentColor.green,
                    blue: $viewModel.currentColor.blue,
                    alpha: nil
                )
            }
        }
    }
}

struct ColorHexChallengeView: View {
    @Bindable var viewModel: ColorGameViewModel
    
    var body: some View {
        BaseGameView(
            instruction: "Match the target color using the RGB sliders!",
            showCheckButton: true,
            onCheck: {
                let result = viewModel.checkColorMatch()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            },
            gameColor: GameConstants.miniGames[2].color
        ) {
            HStack(spacing: 60) {
                ColorPreviewView(
                    color: viewModel.challengeState.targetColor,
                    hexString: viewModel.challengeState.targetHexString,
                    title: "Target Color"
                )
                
                ColorPreviewView(
                    color: viewModel.currentColor.color,
                    hexString: viewModel.currentColor.hexString,
                    title: "Your Color"
                )
            }
            
            ColorSlidersView(
                red: $viewModel.currentColor.red,
                green: $viewModel.currentColor.green,
                blue: $viewModel.currentColor.blue
            )
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: false)
        }
    }
}

struct OpacityChallengeView: View {
    @Bindable var viewModel: ColorGameViewModel
    
    var body: some View {
        BaseGameView(
            instruction: "Match both the color and opacity of the target",
            showCheckButton: true,
            onCheck: {
                let result = viewModel.checkColorMatch()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            },
            gameColor: GameConstants.miniGames[2].color
        ) {
            HStack(spacing: 60) {
                ColorPreviewView(
                    color: viewModel.challengeState.targetColor.opacity(viewModel.challengeState.targetAlpha),
                    hexString: viewModel.challengeState.targetHexString,
                    title: "Target Color",
                    showCheckerboard: true
                )
                
                ColorPreviewView(
                    color: viewModel.currentColor.color.opacity(viewModel.currentColor.alpha),
                    hexString: viewModel.currentColor.hexString,
                    title: "Your Color",
                    showCheckerboard: true
                )
            }
            
            ColorSlidersView(
                red: $viewModel.currentColor.red,
                green: $viewModel.currentColor.green,
                blue: $viewModel.currentColor.blue,
                alpha: Binding(
                    get: { viewModel.currentColor.alpha },
                    set: { viewModel.currentColor.alpha = $0 }
                )
            )
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: true)
        }
    }
}

struct ReversedChallengeView: View {
    @Bindable var viewModel: ColorGameViewModel
    
    var body: some View {
        BaseGameView(
            instruction: "Select the color that matches the given RGB-alpha value!",
            showCheckButton: true,
            onCheck: {
                if let selectedIndex = viewModel.reversedChallengeState.selectedOptionIndex {
                    let result = viewModel.reversedChallengeState.checkAnswer(selectedIndex: selectedIndex)
                    viewModel.isCorrect = result.isCorrect
                    viewModel.hintMessage = result.message
                    viewModel.showHint = true
                }
            },
            gameColor: GameConstants.miniGames[2].color
        ) {
            VStack(spacing: 40) {
                // Target color display
                VStack(spacing: 10) {
                    Text("Misterious Color")
                        .font(GameTheme.subheadingFont)
                    
                    Text(viewModel.reversedChallengeState.targetHexString)
                        .font(GameTheme.headingFont)
                        .padding(8)
                        .background(Color.gameGray)
                        .cornerRadius(8)
                    
                    Text(String(format: "Opacity: %.0f%%", viewModel.reversedChallengeState.targetAlpha * 100))
                        .font(GameTheme.bodyFont)
                }
                
                // Color options
                HStack(spacing: 30) {
                    ForEach(0..<3, id: \.self) { index in
                        ColorOptionView(
                            color: viewModel.reversedChallengeState.options[index],
                            isSelected: viewModel.reversedChallengeState.selectedOptionIndex == index,
                            onTap: {
                                viewModel.reversedChallengeState.selectedOptionIndex = index
                            }
                        )
                    }
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)
            }
        }
        .onAppear {
            viewModel.reversedChallengeState.generateNewChallenge()
        }
    }
}

struct ColorOptionView: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                CheckerboardBackground()
                Circle()
                    .fill(color)
                    .frame(width: 150, height: 150)
                
                if isSelected {
                    Circle()
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 150, height: 150)
                }
            }
            .clipShape(Circle())
            .shadow(radius: 3)
            .onTapGesture(perform: onTap)
        }
    }
}

struct ColorAlphaChallengeView: View {
    @Bindable var viewModel: ColorGameViewModel
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        BaseGameView(
            instruction: "Adjust the opacity to reveal the hidden message!",
            showCheckButton: true,
            onCheck: {
                let result = viewModel.alphaChallengeState.checkAnswer()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            },
            gameColor: GameConstants.miniGames[2].color
        ) {
            HStack(spacing: 50) {
                AlphaGridView(
                    grid: viewModel.alphaChallengeState.grid,
                    opacity: viewModel.alphaChallengeState.opacityValue
                )
                OpacityControlView(
                    opacity: $viewModel.alphaChallengeState.opacityValue,
                    rotationAngle: $rotationAngle
                )
            }
            .padding(40)
            .background(Color.gameBlack.opacity(0.1))
            .cornerRadius(20)
            
            TextField("Enter your answer", text: $viewModel.alphaChallengeState.userAnswer)
                .frame(width: 500)
                .font(GameTheme.headingFont)
                .background(Color.gameBlue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gameBlue.opacity(0.8), lineWidth: 2)
                )
                .padding(.horizontal, 50)
                .multilineTextAlignment(.center)
                .autocapitalization(.allCharacters)
                .autocorrectionDisabled(true)
        }
        .onAppear {
            viewModel.alphaChallengeState.generateNewGrid()
        }
    }
}

// MARK: - Component Views

struct ColorPreviewView: View {
    let color: Color
    let hexString: String
    let title: LocalizedStringResource?
    let showCheckerboard: Bool
    
    init(
        color: Color,
        hexString: String,
        title: LocalizedStringResource? = nil,
        showCheckerboard: Bool = false
    ) {
        self.color = color
        self.hexString = hexString
        self.title = title
        self.showCheckerboard = showCheckerboard
    }
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .font(GameTheme.subheadingFont)
            }
            
            ZStack {
                if showCheckerboard {
                    CheckerboardBackground()
                }
                Circle()
                    .fill(color)
                    .frame(width: 150, height: 150)
            }
            .clipShape(Circle())
            .shadow(radius: 5)
            
            Text(hexString)
                .font(GameTheme.bodyFont)
                .padding(8)
                .background(Color.gameGray)
                .cornerRadius(8)
        }
    }
}

struct ColorSlidersView: View {
    @Binding var red: Double
    @Binding var green: Double
    @Binding var blue: Double
    var alpha: Binding<Double>?
    
    var body: some View {
        HStack {
            VStack(spacing: 20) {
                ColorSlider(value: $red, color: .red)
                ColorSlider(value: $green, color: .green)
                ColorSlider(value: $blue, color: .blue)
            }
            if let alpha = alpha {
                VStack(spacing: 20) {
                    ColorSlider(value: alpha, color: .gray.opacity(0.5))
                }
            }
        }
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
                .font(GameTheme.buttonFont)
        }
        .padding()
        .background(Color.gameGray.opacity(0.3))
        .cornerRadius(15)
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

struct OpacityControlView: View {
    @Binding var opacity: Double
    @Binding var rotationAngle: Double
    @State private var previousAngle: Double = 0
    @State private var continuousAngle: Double = 0
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.6))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 50, height: 50)
                    .offset(x: 35, y: -35)
                    .rotationEffect(.degrees(continuousAngle))
                    .animation(.smooth(duration: 0.3), value: continuousAngle)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Calculate the angle from the center of the circle
                        let center = CGPoint(x: 100, y: 100)
                        let point = value.location
                        
                        // Calculate angle in radians and convert to degrees
                        let angle = atan2(point.y - center.y, point.x - center.x) * 180 / .pi
                        
                        // Account for angle difference to create continuous rotation
                        let angleDifference = angle - previousAngle
                        
                        // Adjust for cases where we cross the 180/-180 boundary
                        var adjustedDifference = angleDifference
                        if angleDifference > 180 {
                            adjustedDifference -= 360
                        } else if angleDifference < -180 {
                            adjustedDifference += 360
                        }
                        
                        // Update continuous angle
                        continuousAngle += adjustedDifference
                        
                        // Update rotation and opacity
                        rotationAngle = angle
                        previousAngle = angle
                        
                        // Set opacity based on distance from center (optional)
                        let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
                        let normalizedDistance = min(max(distance / 100, 0), 1)
                        opacity = normalizedDistance
                    }
                    .onEnded { _ in
                        // Optional: you could add ending animation or reset behavior here
                        previousAngle = rotationAngle
                    }
            )
        }
    }
}

struct AlphaGridView: View {
    let grid: [[ColorGameViewModel.AlphaChallengeState.AlphaSquare]]
    let opacity: Double
    
    var body: some View {
        VStack {
            VStack(spacing: 2) {
                ForEach(0..<min(grid.count, 4), id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<min(grid[row].count, 4), id: \.self) { col in
                            let square = grid[row][col]
                            // Opacity changes more gradual with exponential formula
                            let adjustedOpacity = pow(opacity, 1.5)
                            let squareOpacity = square.baseAlpha * (square.increasesOpacity ? adjustedOpacity : (1 - adjustedOpacity))
                            ZStack {
                                Rectangle()
                                    .fill(Color.gameBlue.opacity(squareOpacity))
                                    .frame(width: 60, height: 60)
                                
                                if !square.letter.isEmpty {
                                    Text(square.letter)
                                        .font(GameTheme.bodyFont)
                                        .foregroundColor(.gameBlue.opacity(square.letterOpacity))
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.gameBlue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Previews

extension ColorGameView {
    static func previewWithPhase(_ phase: GamePhase) -> some View {
        let viewModel = ColorGameViewModel()
        viewModel.currentPhase = phase
        return ColorGameView(viewModel: viewModel)
            .environment(\.colorScheme, .light)
            .environmentObject(NavigationState())
            .environmentObject(UserViewModel())
    }
}

#Preview("Intro") {
    ColorGameView.previewWithPhase(.introDialogue)
}

#Preview("Questions") {
    ColorGameView.previewWithPhase(.questions)
}

#Preview("Exploration") {
    ColorGameView.previewWithPhase(.exploration)
}

#Preview("Novice") {
    ColorGameView.previewWithPhase(.noviceChallenge)
}

#Preview("Apprentice") {
    ColorGameView.previewWithPhase(.apprenticeChallenge)
}

#Preview("Adept") {
    ColorGameView.previewWithPhase(.adeptChallenge)
}

#Preview("Expert") {
    ColorGameView.previewWithPhase(.expertChallenge)
}

#Preview("Review") {
    ColorGameView.previewWithPhase(.review)
}
