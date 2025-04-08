import SwiftUI

struct QuestionsView: View {
    var questions: [Question]
    @StateObject var viewModel: QuestionsViewModel
    @Binding var currentPhase: GamePhase
    @EnvironmentObject var userProgress: UserProgressModel
    
    init(questions: [Question], currentPhase: Binding<GamePhase>) {
        self.questions = questions
        self._currentPhase = currentPhase
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
                    .frame(width: 660, height: 450)
                
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
                        let sortedKeys = viewModel.questions[viewModel.currentQuestionIndex].alternatives.keys.sorted()
                        
                        ForEach(sortedKeys.indices, id: \.self) { index in
                            let alternativeID = sortedKeys[index]
                            let letter = letters[index]
                            
                            HStack {
                                // Letter Button (A, B, C, D)
                                Button(action: {
                                    viewModel.selectAnswer(alternativeID)
                                }) {
                                    Text(letter)
                                        .font(GameTheme.buttonFont)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            viewModel.selectedAnswers[viewModel.currentQuestionIndex] == alternativeID ?
                                            (viewModel.isAnswerCorrect ? Color.green : Color.red) :
                                            Color.gray
                                        )
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                .disabled(viewModel.showExplanation)
                                
                                // Alternative Text
                                Text(viewModel.questions[viewModel.currentQuestionIndex].alternatives[alternativeID] ?? "")
                                    .font(GameTheme.bodyFont)
                                    .foregroundColor(.black)
                                    .frame(minWidth: 400, maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .frame(width: 500)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    if viewModel.showExplanation {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(viewModel.isAnswerCorrect ? "Correct! 🎉" : "Not quite right 😕")
                                .font(.headline)
                                .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                            
                            Text(viewModel.currentExplanation)
                                .font(.body)
                                .foregroundColor(.gameDarkBlue)
                                .padding(.vertical, 5)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.top, 20)
                    }
                }
                
                // Character Icon
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.gameBlue)
                    .offset(x: -400)
                    .zIndex(1)
            }
            
            Spacer()
            
            // Progress and Next Button
            HStack {
                // Progress Indicator
                Text("\(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Next Button
                AnimatedCircleButton(
                    iconName: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill",
                    color: .gameLightBlue,
                    action: {
                        if viewModel.nextQuestion() {
                            // Save progress and move to next phase
                            userProgress.completeGame("Questions", score: Int(viewModel.getProgress() * 100))
                            currentPhase.next()
                        }
                    }
                )
                .padding()
                .disabled(!viewModel.showExplanation)
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea()
    }
}

#Preview {
    @State var previewPhase = GamePhase.challenges
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
        )
    ]
    return QuestionsView(questions: sampleQuestions, currentPhase: $previewPhase)
        .environmentObject(UserProgressModel())
}
