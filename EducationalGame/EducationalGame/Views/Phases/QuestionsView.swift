import SwiftUI

struct QuestionsView: View {
    var questions: [Question]
    @StateObject var viewModel: QuestionsViewModel
    @Binding var currentPhase: GamePhase
    var color: Color
    var gameType: String
    
    init(questions: [Question], currentPhase: Binding<GamePhase>, color: Color, gameType: String = "Binary Game") {
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
                    .frame(width: 660, height: 500)
                
                // Display the current question text
                VStack {
                    Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                        .font(GameTheme.bodyFont)
                        .foregroundColor(.gameDarkBlue)
                        .padding(40)
                        .frame(width: 600, alignment: .leading)
                    
                    VStack(spacing: 15) {
                        // Map numeric alternative keys (1-4) to lettered options (A-D)
                        let letters = ["A", "B", "C", "D"]
                        // Use randomized keys instead of sorted keys
                        let randomizedKeys = viewModel.getRandomizedKeys()
                        let currentQuestion = viewModel.questions[viewModel.currentQuestionIndex]
                        let selectedAnswer = viewModel.selectedAnswers[viewModel.currentQuestionIndex]
                        let correctAnswer = currentQuestion.correctAnswer
                        
                        ForEach(randomizedKeys.indices, id: \.self) { index in
                            let alternativeID = randomizedKeys[index]
                            let letter = letters[index]
                            
                            // Only show if:
                            // 1. We're not showing the explanation yet, OR
                            // 2. This is the selected answer, OR
                            // 3. This is the correct answer
                            if !viewModel.showExplanation || alternativeID == selectedAnswer || alternativeID == correctAnswer {
                                // Make the whole row clickable
                                Button(action: {
                                    if !viewModel.showExplanation {
                                        viewModel.selectAnswer(alternativeID)
                                    }
                                }) {
                                    HStack {
                                        // Letter Button (A, B, C, D)
                                        Text(letter)
                                            .font(GameTheme.buttonFont)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                viewModel.selectedAnswers[viewModel.currentQuestionIndex] == alternativeID ?
                                                    (viewModel.isAnswerCorrect ? Color.green : Color.red) :
                                                    (viewModel.showExplanation && alternativeID == correctAnswer ? Color.green : Color.gray)
                                            )
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                        
                                        // Alternative Text
                                        Text(viewModel.questions[viewModel.currentQuestionIndex].alternatives[alternativeID] ?? "")
                                            .font(GameTheme.bodyFont)
                                            .foregroundColor(.gameBlack)
                                            .frame(minWidth: 400, maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .background(
                                                (viewModel.showExplanation && alternativeID == correctAnswer) ?
                                                    Color.green.opacity(0.2) :
                                                    Color.gray.opacity(0.2)
                                            )
                                            .cornerRadius(10)
                                    }
                                    .frame(width: 500)
                                    .contentShape(Rectangle()) // Ensure the entire HStack is clickable
                                }
                                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                                .disabled(viewModel.showExplanation)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.showExplanation)
                            }
                        }
                        
                        // Explanation appears in the same box, below the alternatives
                        if viewModel.showExplanation {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(viewModel.isAnswerCorrect ? "Correct! 🎉" : "Not quite right 😕")
                                    .font(.headline)
                                    .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                                
                                Text(viewModel.currentExplanation)
                                    .font(.body)
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
            
            // Navigation buttons (Back, Progress indicator, Next)
            HStack {
                // Back Button (only visible if not on first question)
                if viewModel.currentQuestionIndex > 0 {
                    AnimatedCircleButton(
                        iconName: "arrow.left.circle.fill",
                        color: .gameGray,
                        action: {
                            viewModel.previousQuestion()
                        }
                    )
                    .padding(.leading, 20)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: viewModel.currentQuestionIndex)
                } else {
                    // Empty space to maintain layout when back button is not visible
                    Spacer()
                        .frame(width: 70)
                }
                
                // Progress Indicator
                VStack(spacing: 5) {
                    Text("\(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                        .font(.headline)
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
                        if viewModel.nextQuestion() {
                            // We've completed all questions, move to next phase
                            let percentage = viewModel.getProgress()
                            
                            // Save progress
                            sharedUserViewModel.completeMiniGame(
                                gameType + " Questions",
                                score: Int(percentage * 100),
                                percentage: percentage
                            )
                            currentPhase.next(for: gameType)
                        }
                    }
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
            return .gameLightBlue // Current question
        } else if viewModel.isQuestionAnswered(index) {
            return .green // Answered question
        } else {
            return .gray.opacity(0.3) // Unanswered question
        }
    }
}

#Preview {
    @Previewable @State var previewPhase = GamePhase.challenges
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
    return QuestionsView(questions: sampleQuestions, currentPhase: $previewPhase, color: .gameGreen)
}
