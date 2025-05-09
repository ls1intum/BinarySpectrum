import SwiftUI

struct BinaryGameView: View {
    @Bindable var viewModel: BinaryGameViewModel
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    init(viewModel: BinaryGameViewModel = BinaryGameViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer().frame(height: 90)
                currentPhaseView
            }
            
            TopBar(title: GameConstants.miniGames[0].name, color: GameConstants.miniGames[0].color)
            
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
    }

    @ViewBuilder
    private var currentPhaseView: some View {
        switch viewModel.currentPhase {
        case .introDialogue, .tutorialDialogue, .lastDialogue:
            DialogueView(
                personaImage: GameConstants.miniGames[0].personaImage,
                color: GameConstants.miniGames[0].color,
                dialogues: dialogueContent,
                gameType: viewModel.gameType,
                currentPhase: $viewModel.currentPhase
            )
        case .questions:
            QuestionsView(
                questions: viewModel.introQuestions,
                currentPhase: $viewModel.currentPhase,
                color: GameConstants.miniGames[0].color,
                gameType: viewModel.gameType
            )
        case .exploration:
            BinaryExplorationView(viewModel: viewModel)
        case .noviceChallenge:
            BinaryNoviceChallengeView(viewModel: viewModel)
        case .apprenticeChallenge:
            BinaryApprenticeChallengeView(viewModel: viewModel)
        case .adeptChallenge:
            BinaryAdeptChallengeView(viewModel: viewModel)
        case .expertChallenge:
            BinaryExpertChallengeView(viewModel: viewModel)
        case .review:
            ReviewView(
                title: "Binary Numbers",
                items: viewModel.reviewCards.map { card in
                    ReviewItem(
                        title: card.title,
                        content: card.content,
                        example: card.example
                    )
                },
                color: GameConstants.miniGames[0].color,
                onCompletion: {
                    viewModel.completeGame(score: 50, percentage: 1.0)
                }
            )
        case .reward:
            RewardView(miniGameIndex: 0, message: viewModel.rewardMessage)
                .environmentObject(navigationState)
                .environmentObject(userViewModel)
        }
    }

    private var dialogueContent: [LocalizedStringResource] {
        switch viewModel.currentPhase {
        case .introDialogue: return viewModel.introDialogue
        case .tutorialDialogue: return viewModel.practiceDialogue
        case .lastDialogue: return viewModel.finalDialogue
        default: return []
        }
    }
}

// MARK: - Base Views

struct BinaryChallengeBaseView<Content: View>: View {
    @Bindable var viewModel: BinaryGameViewModel
    let instruction: LocalizedStringResource
    let content: Content
    let showCheckButton: Bool
    let onCheck: () -> Void
    
    init(
        viewModel: BinaryGameViewModel,
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
                            color: GameConstants.miniGames[0].color,
                            action: {
                                // Show info popup with appropriate message based on the check
                                onCheck()
                            }
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Challenges

struct BinaryExplorationView: View {
    @Bindable var viewModel: BinaryGameViewModel
    
    var body: some View {
        BinaryChallengeBaseView(
            viewModel: viewModel,
            instruction: "Select a number to see its binary representation",
            onCheck: {
                viewModel.nextPhase()
            }
        ) {
            VStack(spacing: 30) {
                HStack(spacing: 10) {
                    ForEach(Array(stride(from: 7, through: 0, by: -1)), id: \.self) { number in
                        Button(action: {
                            viewModel.explorationState.selectedNumber = number
                        }) {
                            Text("\(number)")
                                .font(GameTheme.headingFont)
                                .frame(width: 60, height: 60)
                                .background(viewModel.explorationState.selectedNumber == number ? Color.gamePink.opacity(0.8) : Color.gameGray.opacity(0.3))
                                .foregroundColor(.gameBlack)
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(spacing: 15) {
                    Text("Binary Representation")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameBlack)
                    
                    let binaryString = String(viewModel.explorationState.selectedNumber, radix: 2).paddingLeft(with: "0", toLength: 3)
                    let binaryDigits = binaryString.map { String($0) }
                    
                    HStack(spacing: 16) {
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 8) {
                                VStack {
                                    Text("\(Int(pow(2.0, Double(2 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gameDarkBlue)
                                    
                                    Text(binaryDigits[index])
                                        .font(GameTheme.subheadingFont)
                                        .frame(width: 50, height: 50)
                                        .background(Color.gameGreen.opacity(0.8))
                                        .foregroundColor(.gameBlack)
                                        .cornerRadius(12)
                                }
                                
                                let power = Int(pow(2.0, Double(2 - index)))
                                let digit = Int(binaryDigits[index]) ?? 0
                                VStack{
                                    Spacer()
                                    HStack{
                                        Text("\(digit) × \(power) =")
                                            .font(GameTheme.subheadingFont)
                                            .foregroundColor(.gameBlack)
                                        Text("\(digit * power)")
                                            .font(GameTheme.subheadingFont)
                                            .foregroundColor(.gamePurple)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Calculate the sum of all digit * power values
                    let sumComponents = (0..<3).map { index in
                        let power = Int(pow(2.0, Double(2 - index)))
                        let digit = Int(binaryDigits[index]) ?? 0
                        return digit * power
                    }
                    
                    let sumString = sumComponents.map { "\($0)" }.joined(separator: " + ")
                    
                    (
                        Text("\(sumString) = ")
                            .foregroundColor(.gamePurple)
                        + Text("\(viewModel.explorationState.selectedNumber)")
                            .foregroundColor(.gamePink)
                    )
                    .font(GameTheme.subheadingFont)
                    .padding(.top, 10)
                    
                    (
                        Text("\(viewModel.explorationState.selectedNumber)")
                            .foregroundColor(.gamePink)
                        + Text(" in binary is ")
                            .foregroundColor(.gameBlack)
                        + Text(binaryString)
                            .foregroundColor(.gameGreen)
                    )
                    .font(GameTheme.subheadingFont)
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)
            }
        }
    }
}

struct BinaryNoviceChallengeView: View {
    @Bindable var viewModel: BinaryGameViewModel
    
    var body: some View {
        BinaryChallengeBaseView(
            viewModel: viewModel,
            instruction: "Tap the circles to toggle between 0 and 1. Your goal is to represent \(viewModel.noviceState.targetNumber) in binary.",
            onCheck: {
                viewModel.checkNoviceAnswer()
            }
        ) {
            HStack(spacing: 30) {
                Spacer()
                VStack(spacing: 30) {
 
                    
                    HStack(spacing: 16) {
                        ForEach(0..<viewModel.noviceState.digitCount, id: \.self) { index in
                            VStack {
                                Text("\(Int(pow(2.0, Double(viewModel.noviceState.digitCount - 1 - index))))")
                                    .font(GameTheme.captionFont)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.noviceState.binaryDigits[index] = (viewModel.noviceState.binaryDigits[index] == "0") ? "1" : "0"
                                    }
                                }) {
                                    Text(viewModel.noviceState.binaryDigits[index])
                                        .font(GameTheme.headingFont)
                                        .frame(width: 75, height: 75)
                                        .background(viewModel.noviceState.binaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                        .foregroundColor(.gameBlack)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    Spacer()
                    Text("\(viewModel.noviceState.decimalValue)")
                        .font(GameTheme.headingFont)
                        .frame(width: 85, height: 85)
                        .background(Color.gameGray.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)

                Spacer()
                VStack(spacing: 8) {
                    Text("Target")
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameDarkBlue)
                    
                    Text("\(viewModel.noviceState.targetNumber)")
                        .font(GameTheme.subtitleFont)
                        .frame(width: 100, height: 100)
                        .background(Color.gamePurple.opacity(0.8))
                        .foregroundColor(.gameWhite)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                Spacer()
            }
        }
    }
}

struct BinaryApprenticeChallengeView: View {
    @Bindable var viewModel: BinaryGameViewModel
    
    var body: some View {
        BinaryChallengeBaseView(
            viewModel: viewModel,
            instruction: "Now lets represent \(viewModel.apprenticeState.targetNumber) in binary. For that we need 5 digits!",
            onCheck: {
                viewModel.checkApprenticeAnswer()
            }
        ) {
            HStack(spacing: 30) {
                Spacer()
                VStack(spacing: 80) {
                    HStack(spacing: 16) {
                        ForEach(0..<viewModel.apprenticeState.digitCount, id: \.self) { index in
                            VStack {
                                Text("\(Int(pow(2.0, Double(viewModel.apprenticeState.digitCount - 1 - index))))")
                                    .font(GameTheme.captionFont)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.apprenticeState.binaryDigits[index] = (viewModel.apprenticeState.binaryDigits[index] == "0") ? "1" : "0"
                                    }
                                }) {
                                    Text(viewModel.apprenticeState.binaryDigits[index])
                                        .font(GameTheme.headingFont)
                                        .frame(width: 75, height: 75)
                                        .background(viewModel.apprenticeState.binaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                        .foregroundColor(.gameBlack)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    
                    Text("\(viewModel.apprenticeState.decimalValue)")
                        .font(GameTheme.headingFont)
                        .frame(width: 85, height: 85)
                        .background(Color.gameGray.opacity(0.3))
                        .cornerRadius(12)
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)
                
                Spacer()
                VStack(spacing: 8) {
                    Text("Target")
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameDarkBlue)
                    
                    Text("\(viewModel.apprenticeState.targetNumber)")
                        .font(GameTheme.subtitleFont)
                        .frame(width: 100, height: 100)
                        .background(Color.gamePurple.opacity(0.8))
                        .foregroundColor(.gameWhite)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                Spacer()
            }
        }
    }
}

struct BinaryAdeptChallengeView: View {
    @Bindable var viewModel: BinaryGameViewModel
    
    var body: some View {
        BinaryChallengeBaseView(
            viewModel: viewModel,
            instruction: "Now let's convert binary to decimal! What number is represented by these binary digits?",
            onCheck: {
                viewModel.checkAdeptAnswer()
            }
        ) {
            HStack(spacing: 30) {
                Spacer()
                VStack(spacing: 8) {
                    Text("Your Answer")
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameDarkBlue)
                    
                    TextField("?", text: $viewModel.adeptState.userDecimalAnswer)
                        .keyboardType(.numberPad)
                        .font(GameTheme.headingFont)
                        .frame(width: 100, height: 100)
                        .background(Color.gameGreen.opacity(0.8))
                        .foregroundColor(.gameBlack)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled(true)
                }
                Spacer()
                VStack {
                    HStack(spacing: 16) {
                        ForEach(0..<viewModel.adeptState.digitCount, id: \.self) { index in
                            VStack {
                                Text("\(Int(pow(2.0, Double(viewModel.adeptState.digitCount - 1 - index))))")
                                    .font(GameTheme.captionFont)
                                    .foregroundColor(.gray)
                                
                                Text(viewModel.adeptState.binaryDigits[index])
                                    .font(GameTheme.headingFont)
                                    .frame(width: 85, height: 85)
                                    .background(viewModel.adeptState.binaryDigits[index] == "1" ? Color.gamePurple.opacity(0.8) : Color.gameGray.opacity(0.3))
                                    .foregroundColor(viewModel.adeptState.binaryDigits[index] == "1" ? .gameWhite : .gameBlack)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)
                Spacer()
            }
        }
    }
}

struct BinaryExpertChallengeView: View {
    @Bindable var viewModel: BinaryGameViewModel
    
    var body: some View {
        BinaryChallengeBaseView(
            viewModel: viewModel,
            instruction: "Create your binary armband based on your birthdate",
            onCheck: {
                viewModel.checkBirthdateChallenge()
            }
        ) {
            VStack(spacing: 25) {
                HStack(spacing: 30) {
                    VStack(alignment: .center, spacing: 15) {
                        Text("Day (1-31)")
                            .font(GameTheme.bodyFont)
                        
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.expertState.dayBinaryDigits.count, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.expertState.dayBinaryDigits.count - 1 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.expertState.dayBinaryDigits[index] = (viewModel.expertState.dayBinaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.expertState.dayBinaryDigits[index])
                                            .font(GameTheme.headingFont)
                                            .frame(width: 85, height: 85)
                                            .background(viewModel.expertState.dayBinaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.gameBlack)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                        }
                        
                        Text(viewModel.expertState.dayDecimalValue == 0 ? " " : "\(viewModel.expertState.dayDecimalValue).")
                            .font(GameTheme.subheadingFont)
                            .foregroundColor(.gameBlack)
                    }
                    VStack(alignment: .center, spacing: 15) {
                        Text("Month (1-12)")
                            .font(GameTheme.bodyFont)
                        
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.expertState.monthBinaryDigits.count, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.expertState.monthBinaryDigits.count - 1 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.expertState.monthBinaryDigits[index] = (viewModel.expertState.monthBinaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.expertState.monthBinaryDigits[index])
                                            .font(GameTheme.headingFont)
                                            .frame(width: 85, height: 85)
                                            .background(viewModel.expertState.monthBinaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.gameBlack)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                        }
                        
                        Text(viewModel.expertState.monthStringValue)
                            .font(GameTheme.subheadingFont)
                            .foregroundColor(.gameBlack)
                    }
                }
                .padding()
                .background(Color.gameGray.opacity(0.3))
                .cornerRadius(15)
                Spacer()
                if viewModel.expertState.isBirthdateValid {
                    BinaryArmbandView(monthBits: viewModel.expertState.monthBinaryDigits, dayBits: viewModel.expertState.dayBinaryDigits, favColor: viewModel.favoriteColor)
                        .padding(.vertical)
                    Spacer()
                }
            }
        }
    }
}

struct BinaryArmbandView: View {
    let monthBits: [String]
    let dayBits: [String]
    let favColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Your Binary Armband")
                .font(GameTheme.headingFont)
                .foregroundColor(.gameDarkBlue)
            
            HStack(spacing: 2) {
                ZStack {
                    // "Band"
                    Rectangle()
                        .fill(Color.gameDarkBlue)
                        .frame(width: 500, height: 2)
                    
                    // "Pearls"
                    HStack(spacing: 2) {
                        ForEach(dayBits, id: \.self) { bit in
                            Circle()
                                .fill(bit == "1" ? favColor : Color.white)
                                .overlay(
                                    Circle().stroke(Color.gameDarkBlue, lineWidth: 2)
                                )
                                .frame(width: 30, height: 30)
                        }
                        Rectangle()
                            .fill(Color.gameBlack)
                            .frame(width: 2, height: 30)
                        ForEach(monthBits, id: \.self) { bit in
                            Circle()
                                .fill(bit == "1" ? favColor : Color.white)
                                .overlay(
                                    Circle().stroke(Color.gameDarkBlue, lineWidth: 2)
                                )
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.gameBlack.opacity(0.1))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.gameGray.opacity(0.3))
        .cornerRadius(15)
    }
}

// MARK: - Previews

#Preview("Intro") {
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

#Preview("Exploration") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .exploration
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Novice Challenge") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .noviceChallenge
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Apprentice Challenge") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .apprenticeChallenge
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Adept Challenge") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .adeptChallenge
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Expert Challenge") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .expertChallenge
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Review") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .review
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
