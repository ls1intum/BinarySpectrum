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
                    color: GameConstants.miniGames[0].color,
                    dialogues: viewModel.introDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .questions:
                Questions(viewModel: viewModel)
            case .exploration:
                BinaryExplorationView(viewModel: viewModel)
            case .tutorial:
                DialogueView(
                    personaImage: GameConstants.miniGames[0].personaImage,
                    color: GameConstants.miniGames[0].color,
                    dialogues: viewModel.practiceDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .practice:
                BinaryLearningGame(viewModel: viewModel)
            case .challenges:
                BinaryChallengeView(viewModel: viewModel)
            case .advancedChallenges:
                BinaryAdvancedChallengeView(viewModel: viewModel)
            case .finalChallenge:
                BinaryFinalChallengeView(viewModel: viewModel)
            case .review:
                BinaryReviewView(viewModel: viewModel)
            case .reward:
                RewardView(
                    message: "Outstanding achievement! You've mastered the language of computers - binary numbers! From basic conversions to creating your own binary armband, you now understand how computers represent and process all information using just 0s and 1s. This fundamental knowledge is the building block of all digital technology. You're thinking like a true computer scientist!",
                    personaImage: GameConstants.miniGames[0].personaImage,
                    badgeTitle: "Binary Master! 🔢",
                    color: GameConstants.miniGames[0].color
                )
            }
        }
    }
}

struct Questions: View {
    @State var viewModel: BinaryGameViewModel
    
    var body: some View {
        QuestionsView(
            questions: viewModel.introQuestions,
            currentPhase: $viewModel.currentPhase,
            color: GameConstants.miniGames[0].color,
            gameType: viewModel.gameType
        )
    }
}

struct BinaryLearningGame: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Tap the circles to toggle between 0 and 1. Your goal is to represent \(viewModel.targetNumber) in binary.")
            Spacer()
            
            HStack(spacing: 30) {
                Spacer()
                VStack {
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
                                        .frame(width: 75, height: 75)
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
                        .frame(width: 85, height: 85)
                        .background(Color.gameGray.opacity(0.3))
                        .cornerRadius(12)
                }
                Spacer()
                VStack(spacing: 8) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.targetNumber)")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 85, height: 85)
                        .background(Color.gameLightBlue.opacity(0.8))
                        .foregroundColor(.black)
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
                            showAlert = true
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
        .alert("Result", isPresented: $showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                if isCorrect {
                    // Complete this challenge and advance
                    viewModel.completeGame(score: 100, percentage: 1.0)
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct BinaryExplorationView: View {
    @State var viewModel: BinaryGameViewModel
    
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
                            viewModel.selectedNumber = number
                        }) {
                            Text("\(number)")
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 40, height: 40)
                                .background(viewModel.selectedNumber == number ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
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
                    
                let binaryString = String(viewModel.selectedNumber, radix: 2).paddingLeft(with: "0", toLength: 3)
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
                    
                Text("\(viewModel.selectedNumber) in binary is \(binaryString)")
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
                        color: GameConstants.miniGames[0].color,
                        action: {
                            // Complete exploration and update progress
                            viewModel.completeGame(score: 50, percentage: 1.0)
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
    }
}

struct BinaryChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Now lets represent \(viewModel.challengeTargetNumber) in binary. For that we need 5 digits!")
            Spacer()
            
            HStack(spacing: 30) {
                Spacer()
                VStack {
                    HStack(spacing: 16) {
                        ForEach(0..<viewModel.challengeDigitCount, id: \.self) { index in
                            VStack {
                                Text("\(Int(pow(2.0, Double(viewModel.challengeDigitCount - 1 - index))))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.challengeBinaryDigits[index] = (viewModel.challengeBinaryDigits[index] == "0") ? "1" : "0"
                                    }
                                }) {
                                    Text(viewModel.challengeBinaryDigits[index])
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(width: 75, height: 75)
                                        .background(viewModel.challengeBinaryDigits[index] == "1" ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    
                    Text("\(viewModel.challengeDecimalValue)")
                        .font(GameTheme.bodyFont)
                        .frame(width: 85, height: 85)
                        .background(Color.gameGray.opacity(0.3))
                        .cornerRadius(12)
                }
                Spacer()
                VStack(spacing: 8) {
                    Text("Target")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.challengeTargetNumber)")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 85, height: 85)
                        .background(Color.gameLightBlue.opacity(0.8))
                        .foregroundColor(.black)
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
                            showAlert = true
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
        .alert("Result", isPresented: $showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                if isCorrect {
                    // Complete challenge and advance
                    viewModel.completeGame(score: 150, percentage: 1.0)
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct BinaryAdvancedChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Now let's convert binary to decimal! What number is represented by these binary digits?")
            Spacer()
            
            HStack(spacing: 30) {
                Spacer()
                VStack(spacing: 8) {
                    Text("Your Answer")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Enter number", text: $viewModel.userDecimalAnswer)
                        .keyboardType(.numberPad)
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 85, height: 85)
                        .background(Color.gameLightBlue.opacity(0.8))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                VStack {
                    HStack(spacing: 16) {
                        ForEach(0..<viewModel.advancedDigitCount, id: \.self) { index in
                            VStack {
                                Text("\(Int(pow(2.0, Double(viewModel.advancedDigitCount - 1 - index))))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(viewModel.advancedBinaryDigits[index])
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(width: 75, height: 75)
                                    .background(Color.gameRed.opacity(0.8))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }
                        }
                    }
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
                            isCorrect = Int(viewModel.userDecimalAnswer) == viewModel.advancedTargetNumber
                            viewModel.checkAdvancedAnswer()
                            showAlert = true
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
        .alert("Result", isPresented: $showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                if isCorrect {
                    // Complete advanced challenge and advance
                    viewModel.completeGame(score: 200, percentage: 1.0)
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct BinaryFinalChallengeView: View {
    @State var viewModel: BinaryGameViewModel
    @State private var showAlert = false
    @State private var isCorrect = false
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Create your binary armband! Use binary to represent your birth month and day.")
            
            VStack(spacing: 25) {
                Text("Binary Armband")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 30) {
                    VStack(alignment: .center, spacing: 15) {
                        Text("Month (1-12)")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.monthBinaryDigits.count, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.monthBinaryDigits.count - 1 - index))))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.monthBinaryDigits[index] = (viewModel.monthBinaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.monthBinaryDigits[index])
                                            .font(.system(size: 22, weight: .bold))
                                            .frame(width: 50, height: 50)
                                            .background(viewModel.monthBinaryDigits[index] == "1" ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.black)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                        }
                        
                        Text("Value: \(viewModel.monthDecimalValue)")
                            .font(.headline)
                            .foregroundColor(viewModel.isMonthValid ? .black : .red)
                        
                        if !viewModel.isMonthValid {
                            Text("Month must be 1-12")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 15) {
                        Text("Day (1-31)")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.dayBinaryDigits.count, id: \.self) { index in
                                VStack {
                                    Text("\(Int(pow(2.0, Double(viewModel.dayBinaryDigits.count - 1 - index))))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.dayBinaryDigits[index] = (viewModel.dayBinaryDigits[index] == "0") ? "1" : "0"
                                        }
                                    }) {
                                        Text(viewModel.dayBinaryDigits[index])
                                            .font(.system(size: 22, weight: .bold))
                                            .frame(width: 50, height: 50)
                                            .background(viewModel.dayBinaryDigits[index] == "1" ? Color.gameRed.opacity(0.8) : Color.gameGray.opacity(0.3))
                                            .foregroundColor(.black)
                                            .cornerRadius(10)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                        }
                        
                        Text("Value: \(viewModel.dayDecimalValue)")
                            .font(.headline)
                            .foregroundColor(viewModel.isDayValid ? .black : .red)
                        
                        if !viewModel.isDayValid {
                            Text("Day must be 1-31")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if viewModel.isMonthValid && viewModel.isDayValid {
                    Text("Your birthdate in binary: \(viewModel.monthDecimalValue)/\(viewModel.dayDecimalValue)")
                        .font(.headline)
                        .padding(.top, 10)
                        .foregroundColor(viewModel.isBirthdateValid ? .black : .red)
                    
                    if !viewModel.isBirthdateValid {
                        Text("This date does not exist in the calendar")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color.gameGray.opacity(0.1))
            .cornerRadius(15)
            
            if viewModel.isBirthdateValid {
                BinaryArmbandView(monthBits: viewModel.monthBinaryDigits, dayBits: viewModel.dayBinaryDigits)
                    .padding(.vertical)
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
                            showAlert = true
                        }
                    )
                    .padding()
                }
            }
        }
        .padding()
        .alert("Result", isPresented: $showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                if isCorrect {
                    // Complete final challenge and advance
                    viewModel.completeGame(score: 300, percentage: 1.0)
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

struct BinaryArmbandView: View {
    let monthBits: [String]
    let dayBits: [String]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Your Binary Armband")
                .font(.headline)
            
            HStack(spacing: 2) {
                ForEach(monthBits, id: \.self) { bit in
                    Circle()
                        .fill(bit == "1" ? Color.gameRed : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 2, height: 30)
                
                ForEach(dayBits, id: \.self) { bit in
                    Circle()
                        .fill(bit == "1" ? Color.gameRed : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

struct BinaryReviewView: View {
    @State var viewModel: BinaryGameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            InstructionBar(text: "Let's review what you've learned about binary numbers! Scroll down.")
            
            ScrollView {
                VStack(spacing: 25) {
                    ForEach(viewModel.reviewCards, id: \.title) { card in
                        ReviewCard(
                            title: card.title,
                            content: card.content,
                            example: card.example,
                            titleColor: GameConstants.miniGames[0].color
                        )
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity)
            
            VStack {
                HStack {
                    Spacer()
                
                    AnimatedCircleButton(
                        iconName: "arrow.right.circle.fill",
                        color: GameConstants.miniGames[0].color,
                        action: {
                            // Complete review and advance to reward
                            viewModel.completeGame(score: 50, percentage: 1.0)
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
