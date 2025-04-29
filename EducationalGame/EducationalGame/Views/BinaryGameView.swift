import SwiftUI

struct BinaryGameView: View {
    @State private var viewModel: BinaryGameViewModel
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    init(viewModel: BinaryGameViewModel = BinaryGameViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // Top spacing to accommodate the TopBarView
                Spacer().frame(height: 90)
                
                switch viewModel.currentPhase {
                case .intro:
                    DialogueView(
                        personaImage: GameConstants.miniGames[0].personaImage,
                        color: GameConstants.miniGames[0].color,
                        dialogues: viewModel.introDialogue,
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
                case .tutorial:
                    DialogueView(
                        personaImage: GameConstants.miniGames[0].personaImage,
                        color: GameConstants.miniGames[0].color,
                        dialogues: viewModel.practiceDialogue,
                        gameType: viewModel.gameType,
                        currentPhase: $viewModel.currentPhase
                    )
                case .practice:
                    BinaryPracticeView(viewModel: viewModel)
                case .challenges:
                    BinaryChallengeView(viewModel: viewModel)
                case .advancedChallenges:
                    BinaryAdvancedChallengeView(viewModel: viewModel)
                case .lastDialogue:
                    DialogueView(
                        personaImage: GameConstants.miniGames[0].personaImage,
                        color: GameConstants.miniGames[0].color,
                        dialogues: viewModel.finalDialogue,
                        gameType: viewModel.gameType,
                        currentPhase: $viewModel.currentPhase
                    )
                case .finalChallenge:
                    BinaryFinalChallengeView(viewModel: viewModel, favColor: viewModel.favoriteColor)
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
            TopBar(title: GameConstants.miniGames[0].name, color: GameConstants.miniGames[0].color)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct BinaryExplorationView: View {
    @State var viewModel: BinaryGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                InstructionBar(text: "Select a number to see its binary representation")
                Spacer()
                
                HStack(spacing: 10) {
                    ForEach(0..<8) { number in
                        Button(action: {
                            viewModel.selectedNumber = number
                        }) {
                            Text("\(number)")
                                .font(GameTheme.headingFont)
                                .frame(width: 60, height: 60)
                                .background(viewModel.selectedNumber == number ? Color.gamePink.opacity(0.8) : Color.gameGray.opacity(0.3))
                                .foregroundColor(.gameBlack)
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(spacing: 15) {
                    Text("Binary Representation")
                        .font(GameTheme.headingFont)
                        .foregroundColor(.gameBlack)
                    
                    let binaryString = String(viewModel.selectedNumber, radix: 2).paddingLeft(with: "0", toLength: 3)
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
                                
                                Text("\(digit) × \(power) =")
                                    .font(GameTheme.subheadingFont)
                                    .foregroundColor(.gameBlack)
                                Text("\(digit * power)")
                                    .font(GameTheme.subheadingFont)
                                    .foregroundColor(.gamePurple)
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
                            + Text("\(viewModel.selectedNumber)")
                            .foregroundColor(.gamePink)
                    )
                    .font(GameTheme.subheadingFont)
                    .padding(.top, 10)
                    
                    (
                        Text("\(viewModel.selectedNumber)")
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
                
                Spacer()
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AnimatedCircleButton(
                            iconName: "arrow.right.circle.fill",
                            color: GameConstants.miniGames[0].color,
                            action: {
                                viewModel.currentPhase.next(for: viewModel.gameType)
                            }
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

struct BinaryPracticeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var showPopup = false
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                InstructionBar(text: "Tap the circles to toggle between 0 and 1. Your goal is to represent \(viewModel.targetNumber) in binary.")
                Spacer()
                
                HStack(spacing: 30) {
                    Spacer()
                    VStack {
                        HStack(spacing: 16) {
                            ForEach(0..<viewModel.digitCount, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.digitCount - 1 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.binaryDigits[index] = (viewModel.binaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.binaryDigits[index])
                                            .font(GameTheme.headingFont)
                                            .frame(width: 75, height: 75)
                                            .background(viewModel.binaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.gameBlack)
                                            .cornerRadius(12)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                        }
                        
                        Text("\(viewModel.decimalValue)")
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
                        
                        Text("\(viewModel.targetNumber)")
                            .font(GameTheme.subtitleFont)
                            .frame(width: 100, height: 100)
                            .background(Color.gamePurple.opacity(0.8))
                            .foregroundColor(.gameWhite)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        AnimatedCircleButton(
                            iconName: "checkmark.circle.fill",
                            color: GameConstants.miniGames[0].color,
                            action: {
                                isCorrect = viewModel.decimalValue == viewModel.targetNumber
                                viewModel.checkAnswer()
                                showPopup = true
                            }
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
            
            if showPopup {
                InfoPopup(
                    title: "Result",
                    message: viewModel.alertMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        showPopup = false
                        if isCorrect {
                            // Complete this challenge and advance
                            viewModel.completeGame(score: 100, percentage: 1.0)
                        }
                    }
                )
            }
        }
    }
}

struct BinaryChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var showPopup = false
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                InstructionBar(text: "Now lets represent \(viewModel.challengeTargetNumber) in binary. For that we need 5 digits!")
                Spacer()
                
                HStack(spacing: 30) {
                    Spacer()
                    VStack {
                        HStack(spacing: 16) {
                            ForEach(0..<viewModel.challengeDigitCount, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.challengeDigitCount - 1 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.challengeBinaryDigits[index] = (viewModel.challengeBinaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.challengeBinaryDigits[index])
                                            .font(GameTheme.headingFont)
                                            .frame(width: 75, height: 75)
                                            .background(viewModel.challengeBinaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.gameBlack)
                                            .cornerRadius(12)
                                            .shadow(radius: 3)
                                    }
                                }
                            }
                        }
                        
                        Text("\(viewModel.challengeDecimalValue)")
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
                        
                        Text("\(viewModel.challengeTargetNumber)")
                            .font(GameTheme.subtitleFont)
                            .frame(width: 100, height: 100)
                            .background(Color.gamePurple.opacity(0.8))
                            .foregroundColor(.gameWhite)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                    }
                    Spacer()
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                    
                        AnimatedCircleButton(
                            iconName: "checkmark.circle.fill",
                            color: GameConstants.miniGames[0].color,
                            action: {
                                isCorrect = viewModel.challengeDecimalValue == viewModel.challengeTargetNumber
                                viewModel.checkChallengeAnswer()
                                showPopup = true
                            }
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
            
            if showPopup {
                InfoPopup(
                    title: "Result",
                    message: viewModel.alertMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        showPopup = false
                        if isCorrect {
                            // Complete challenge and advance
                            viewModel.completeGame(score: 150, percentage: 1.0)
                        }
                    }
                )
            }
        }
    }
}

struct BinaryAdvancedChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var showPopup = false
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                InstructionBar(text: "Now let's convert binary to decimal! What number is represented by these binary digits?")
                Spacer()
                
                HStack(spacing: 30) {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Your Answer")
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                        
                        TextField("?", text: $viewModel.userDecimalAnswer)
                            .keyboardType(.numberPad)
                            .font(GameTheme.headingFont)
                            .frame(width: 100, height: 100)
                            .background(Color.gameGreen.opacity(0.8))
                            .foregroundColor(.gameBlack)
                            .cornerRadius(12)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    VStack {
                        HStack(spacing: 16) {
                            ForEach(0..<viewModel.advancedDigitCount, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.advancedDigitCount - 1 - index))))")
                                        .font(GameTheme.captionFont)
                                        .foregroundColor(.gray)
                                    
                                    Text(viewModel.advancedBinaryDigits[index])
                                        .font(GameTheme.headingFont)
                                        .frame(width: 85, height: 85)
                                        .background(viewModel.advancedBinaryDigits[index] == "1" ? Color.gamePurple.opacity(0.8) : Color.gameGray.opacity(0.3))
                                        .foregroundColor(viewModel.advancedBinaryDigits[index] == "1" ? .gameWhite : .gameBlack)
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
                
                Spacer()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AnimatedCircleButton(
                            iconName: "checkmark.circle.fill",
                            color: GameConstants.miniGames[0].color,
                            action: {
                                isCorrect = Int(viewModel.userDecimalAnswer) == viewModel.advancedTargetNumber
                                viewModel.checkAdvancedAnswer()
                                showPopup = true
                            }
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
            
            if showPopup {
                InfoPopup(
                    title: "Result",
                    message: viewModel.alertMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        showPopup = false
                        if isCorrect {
                            // Complete advanced challenge and advance
                            viewModel.completeGame(score: 200, percentage: 1.0)
                        }
                    }
                )
            }
        }
    }
}

struct BinaryFinalChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    let favColor: Color
    @State private var showAlert = false
    @State private var showPopup = false
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                InstructionBar(text: "Create your binary armband based on your birthdate")
                Spacer()
                
                VStack(spacing: 25) {
                    HStack(spacing: 30) {
                        VStack(alignment: .center, spacing: 15) {
                            Text("Day (1-31)")
                                .font(GameTheme.bodyFont)
                            
                            HStack(spacing: 12) {
                                ForEach(0..<viewModel.dayBinaryDigits.count, id: \.self) { index in
                                    VStack {
                                        Text("\(Int(pow(2.0, Double(viewModel.dayBinaryDigits.count - 1 - index))))")
                                            .font(GameTheme.captionFont)
                                            .foregroundColor(.gray)
                                        
                                        Button(action: {
                                            withAnimation {
                                                viewModel.dayBinaryDigits[index] = (viewModel.dayBinaryDigits[index] == "0") ? "1" : "0"
                                            }
                                        }) {
                                            Text(viewModel.dayBinaryDigits[index])
                                                .font(GameTheme.headingFont)
                                                .frame(width: 85, height: 85)
                                                .background(viewModel.dayBinaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                                .foregroundColor(.gameBlack)
                                                .cornerRadius(10)
                                                .shadow(radius: 2)
                                        }
                                    }
                                }
                            }
                            
                            Text("Value: \(viewModel.dayDecimalValue)")
                                .font(GameTheme.subheadingFont)
                                .foregroundColor(.gameBlack)
                        }
                        VStack(alignment: .center, spacing: 15) {
                            Text("Month (1-12)")
                                .font(GameTheme.bodyFont)
                            
                            HStack(spacing: 12) {
                                ForEach(0..<viewModel.monthBinaryDigits.count, id: \.self) { index in
                                    VStack {
                                        Text("\(Int(pow(2.0, Double(viewModel.monthBinaryDigits.count - 1 - index))))")
                                            .font(GameTheme.captionFont)
                                            .foregroundColor(.gray)
                                        
                                        Button(action: {
                                            withAnimation {
                                                viewModel.monthBinaryDigits[index] = (viewModel.monthBinaryDigits[index] == "0") ? "1" : "0"
                                            }
                                        }) {
                                            Text(viewModel.monthBinaryDigits[index])
                                                .font(GameTheme.headingFont)
                                                .frame(width: 85, height: 85)
                                                .background(viewModel.monthBinaryDigits[index] == "1" ? Color.gameGreen.opacity(0.8) : Color.gameGray.opacity(0.3))
                                                .foregroundColor(.gameBlack)
                                                .cornerRadius(10)
                                                .shadow(radius: 2)
                                        }
                                    }
                                }
                            }
                            
                            Text("Value: \(viewModel.monthDecimalValue)")
                                .font(GameTheme.subheadingFont)
                                .foregroundColor(.gameBlack)
                        }
                    }
                    .padding()
                    .background(Color.gameGray.opacity(0.3))
                    .cornerRadius(15)
                    Spacer()
                    if viewModel.isBirthdateValid {
                        BinaryArmbandView(monthBits: viewModel.monthBinaryDigits, dayBits: viewModel.dayBinaryDigits, favColor: favColor)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            }
            
            if showPopup {
                InfoPopup(
                    title: "Result",
                    message: viewModel.alertMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        showPopup = false
                        if isCorrect {
                            // Complete final challenge and advance
                            viewModel.completeGame(score: 300, percentage: 1.0)
                        }
                    }
                )
            }
            Spacer()
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    AnimatedCircleButton(
                        iconName: "checkmark.circle.fill",
                        color: GameConstants.miniGames[0].color,
                        action: {
                            isCorrect = viewModel.isBirthdateValid
                            viewModel.checkBirthdateChallenge()
                            showPopup = true
                        }
                    )
                    .padding(.trailing, 20)
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
                ForEach(dayBits, id: \.self) { bit in
                    Circle()
                        .fill(bit == "1" ? favColor : Color.white)
                        .stroke(Color.gameDarkBlue, lineWidth: 2)
                        .frame(width: 30, height: 30)
                }
                Rectangle()
                    .fill(Color.gameBlack)
                    .frame(width: 2, height: 30)
                ForEach(monthBits, id: \.self) { bit in
                    Circle()
                        .fill(bit == "1" ? favColor : Color.white)
                        .stroke(Color.gameDarkBlue, lineWidth: 2)
                        .frame(width: 30, height: 30)
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

#Preview("Challenges Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .challenges
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Advanced Challenges Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .advancedChallenges
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Last Dialogue Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .lastDialogue
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

#Preview("Reward Phase") {
    let viewModel = BinaryGameViewModel()
    viewModel.currentPhase = .reward
    return BinaryGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
