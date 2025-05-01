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
            VStack {
                Spacer().frame(height: 90)
                currentPhaseView
            }
            
            TopBar(title: GameConstants.miniGames[2].name, color: GameConstants.miniGames[2].color)
            
            if viewModel.showHint {
                InfoPopup(
                    title: viewModel.isCorrect ? "Correct!" : "Try Again",
                    message: viewModel.hintMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        viewModel.showHint = false
                        if viewModel.isCorrect {
                            viewModel.completeGame(score: 100, percentage: 1.0)
                        }
                    }
                )
                .edgesIgnoringSafeArea(.all)
                .zIndex(10)
            }
        }
        .edgesIgnoringSafeArea(.top)
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

// MARK: - Base Views

struct ColorChallengeBaseView<Content: View>: View {
    let viewModel: ColorGameViewModel
    let instruction: LocalizedStringResource
    let content: Content
    let showCheckButton: Bool
    let onCheck: () -> Void
    
    init(
        viewModel: ColorGameViewModel,
        instruction: LocalizedStringResource,
        showCheckButton: Bool = true,
        onCheck: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = viewModel
        self.instruction = instruction
        self.showCheckButton = showCheckButton
        self.onCheck = onCheck
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                InstructionBar(text: instruction)
                Spacer()
                
                content
                
                Spacer()
            }
            if showCheckButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AnimatedCircleButton(
                            iconName: "checkmark.circle.fill",
                            color: GameConstants.miniGames[2].color,
                            action: onCheck
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Challenge Views

struct ColorExplorationView: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ColorChallengeBaseView(
            viewModel: viewModel,
            instruction: "Change the red, green and blue intensity to make your favorite color",
            showCheckButton: true,
            onCheck: { viewModel.nextPhase() }
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
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ColorChallengeBaseView(
            viewModel: viewModel,
            instruction: "Match the target color using the RGB sliders!",
            onCheck: {
                let result = viewModel.checkColorMatch()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            }
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
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ColorChallengeBaseView(
            viewModel: viewModel,
            instruction: "Match both the color and opacity of the target",
            onCheck: {
                let result = viewModel.checkColorMatch()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            }
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
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ColorChallengeBaseView(
            viewModel: viewModel,
            instruction: "Select the color that matches the given RGB-alpha value!",
            showCheckButton: true,
            onCheck: {
                if let selectedIndex = viewModel.reversedChallengeState.selectedOptionIndex {
                    let result = viewModel.reversedChallengeState.checkAnswer(selectedIndex: selectedIndex)
                    viewModel.isCorrect = result.isCorrect
                    viewModel.hintMessage = result.message
                    viewModel.showHint = true
                }
            }
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
    @ObservedObject var viewModel: ColorGameViewModel
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ColorChallengeBaseView(
            viewModel: viewModel,
            instruction: "Adjust the opacity to reveal the hidden message!",
            showCheckButton: true,
            onCheck: {
                let result = viewModel.alphaChallengeState.checkAnswer()
                viewModel.isCorrect = result.isCorrect
                viewModel.hintMessage = result.message
                viewModel.showHint = true
            }
        ) {
            HStack(alignment: .top, spacing: 30) {
                OpacityControlView(
                    opacity: $viewModel.alphaChallengeState.opacityValue,
                    rotationAngle: $rotationAngle
                )
                
                AlphaGridView(
                    grid: viewModel.alphaChallengeState.grid,
                    opacity: viewModel.alphaChallengeState.opacityValue
                )
            }
            .padding()
            
            TextField("Enter your answer", text: $viewModel.alphaChallengeState.userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 500)
                .font(GameTheme.headingFont)
                .padding(.horizontal, 50)
                .multilineTextAlignment(.center)
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
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
                    .rotationEffect(.degrees(rotationAngle))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let height = 200.0
                        let touchY = value.location.y
                        opacity = max(0, min(1, touchY / height))
                        rotationAngle = opacity * 180
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
                            let squareOpacity = square.baseAlpha * (square.increasesOpacity ? opacity : (1 - opacity))
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue.opacity(squareOpacity))
                                    .frame(width: 60, height: 60)
                                
                                if !square.letter.isEmpty {
                                    Text(square.letter)
                                        .font(GameTheme.bodyFont)
                                        .foregroundColor(.blue.opacity(0.8))
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
}

// MARK: - Previews

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
    viewModel.currentPhase = .noviceChallenge
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Opacity match") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .apprenticeChallenge
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Advanced Challenges Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .adeptChallenge
    return ColorGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Final Challenge Phase") {
    let viewModel = ColorGameViewModel()
    viewModel.currentPhase = .expertChallenge
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
