import SwiftUI

struct QuestionsView: View {
    var questions: [Question]
    @StateObject var viewModel: QuestionsViewModel
    @Binding var currentPhase: GamePhase
    var color: Color
    var gameType: String
    
    init(questions: [Question], currentPhase: Binding<GamePhase>, color: Color, gameType: String) {
        self.questions = questions
        self._currentPhase = currentPhase
        self.color = color
        self.gameType = gameType
        self._viewModel = StateObject(wrappedValue: QuestionsViewModel(questions: questions))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Text Box for the Question
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameGray)
                    .shadow(radius: 5)
                    .frame(width: 660, height: 520)
                
                VStack {
                    Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                        .font(GameTheme.bodyFont)
                        .foregroundColor(.gameDarkBlue)
                        .padding(40)
                        .frame(width: 600, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        let letters = ["A", "B", "C", "D"]
                        // Use randomized keys instead of sorted keys
                        let randomizedKeys = viewModel.getRandomizedKeys()
                        let currentQuestion = viewModel.questions[viewModel.currentQuestionIndex]
                        let selectedAnswer = viewModel.selectedAnswers[viewModel.currentQuestionIndex]
                        let correctAnswer = currentQuestion.correctAnswer
                        
                        ForEach(randomizedKeys.indices, id: \.self) { index in
                            let alternativeID = randomizedKeys[index]
                            let letter = letters[index]
                            
                            if !viewModel.showExplanation || alternativeID == selectedAnswer || alternativeID == correctAnswer {
                                Button(action: {
                                    if !viewModel.showExplanation {
                                        viewModel.selectAnswer(alternativeID)
                                        
                                        if alternativeID == correctAnswer {
                                            HapticService.shared.play(.success)
                                            SoundService.shared.playSound(.correct)
                                        } else {
                                            HapticService.shared.play(.error)
                                            SoundService.shared.playSound(.incorrect)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text(letter)
                                            .font(GameTheme.buttonFont)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                viewModel.selectedAnswers[viewModel.currentQuestionIndex] == alternativeID ?
                                                    (viewModel.isAnswerCorrect ? Color.gameGreen : Color.gameRed) :
                                                    (viewModel.showExplanation && alternativeID == correctAnswer ? Color.gameGreen : Color.gray)
                                            )
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                        
                                        Text(viewModel.questions[viewModel.currentQuestionIndex].alternatives[alternativeID] ?? "")
                                            .font(GameTheme.bodyFont)
                                            .foregroundColor(.gameBlack)
                                            .frame(minWidth: 400, maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(
                                                (viewModel.showExplanation && alternativeID == correctAnswer) ?
                                                    Color.gameGreen.opacity(0.2) :
                                                    Color.gray.opacity(0.2)
                                            )
                                            .cornerRadius(10)
                                    }
                                    .frame(width: 500)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(viewModel.showExplanation)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.showExplanation)
                            }
                        }
                        
                        if viewModel.showExplanation {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(viewModel.isAnswerCorrect ? "Correct! 🎉" : "Not quite right 😕")
                                    .font(GameTheme.buttonFont)
                                    .foregroundColor(viewModel.isAnswerCorrect ? .gameGreen : .red)
                                
                                Text(viewModel.currentExplanation)
                                    .font(GameTheme.bodyFont)
                                    .foregroundColor(.gameDarkBlue)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(width: 500, alignment: .leading)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.3), value: viewModel.showExplanation)
                        }
                    }
                }
            }
            Spacer()
            
            // Navigation buttons
            HStack {
                if viewModel.currentQuestionIndex > 0 {
                    AnimatedCircleButton(
                        iconName: "arrow.left.circle.fill",
                        color: .gameGray,
                        action: {
                            viewModel.previousQuestion()
                            HapticService.shared.play(.light)
                            //SoundService.shared.playSound(.button3)
                        },
                        hapticType: .light
                    )
                    .padding(.leading, 20)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: viewModel.currentQuestionIndex)
                } else {
                    Spacer()
                        .frame(width: 70)
                }
                
                // Progress Indicator
                VStack(spacing: 5) {
                    Text("\(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gray)
                    
                    // Dots showing question progress
                    HStack(spacing: 8) {
                        ForEach(0 ..< viewModel.questions.count, id: \.self) { index in
                            Circle()
                                .fill(getProgressDotColor(for: index))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                
                Spacer()
                
                // Next/Finish Button
                AnimatedCircleButton(
                    iconName: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill",
                    color: viewModel.canNavigateToNextQuestion() ? color : .gray,
                    action: {
                        if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                            HapticService.shared.play(.light)
                            //SoundService.shared.playSound(.button4)
                        } else {
                            HapticService.shared.play(.gameSuccess)
                            //SoundService.shared.playSound(.levelUp2)
                        }
                        if viewModel.nextQuestion() {
                            let percentage = viewModel.getProgress()
                            sharedUserViewModel.completeMiniGame(
                                gameType + " Questions",
                                score: Int(percentage * 100),
                                percentage: percentage
                            )
                            if sharedUserViewModel.autoAdjustExperienceLevel {
                                if percentage >= 0.75 {
                                    sharedUserViewModel.setExperienceLevel(.pro, for: gameType)
                                } else {
                                    sharedUserViewModel.setExperienceLevel(.rookie, for: gameType)
                                }
                            }
                            currentPhase.next(for: gameType)
                        }
                    },
                    hapticType: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? .light : .success
                )
                .padding()
                .disabled(!viewModel.canNavigateToNextQuestion())
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
    }
    
    // Helper function to get the color for progress dots
    private func getProgressDotColor(for index: Int) -> Color {
        if index == viewModel.currentQuestionIndex {
            return .gameLightBlue
        } else if viewModel.isQuestionAnswered(index) {
            return .gameGreen
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    @Previewable @State var previewPhase = GamePhase.apprenticeChallenge
    let sampleQuestions: [Question] = [
        Question(
            question: "What is the capital of France?",
            alternatives: [1: "Berlin", 2: "Madrid", 3: "Paris", 4: "Rome"],
            correctAnswer: 3,
            explanation: "Paris is the capital and most populous city of France. It's known as the 'City of Light' and is famous for its art, fashion, and culture."
        ),
        Question(
            question: "Which planet is closest to the Sun?",
            alternatives: [1: "Earth", 2: "Venus", 3: "Mercury", 4: "Mars"],
            correctAnswer: 3,
            explanation: "Mercury is the smallest and innermost planet in the Solar System. It's only about 36 million miles from the Sun."
        ),
        Question(
            question: "How many legs does a spider have?",
            alternatives: [1: "6", 2: "8", 3: "10", 4: "12"],
            correctAnswer: 2,
            explanation: "Spiders have 8 legs."
        )
    ]
    QuestionsView(questions: sampleQuestions, currentPhase: $previewPhase, color: .gameGreen, gameType: "Binary Game")
}
