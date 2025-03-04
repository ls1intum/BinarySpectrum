import SwiftUI

struct QuestionsView: View {
    @State var viewModel: QuestionsViewModel
    @Binding var currentPhase: GamePhase
    
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
                        .onAppear {
                            // Example animation on appearance
                            withAnimation(.easeIn(duration: 1.0)) {
                                // Optionally add some animation on appearance
                            }
                        }
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
                                    // Track the selected answer
                                    viewModel.selectAnswer(alternativeID)
                                }) {
                                    Text(letter)
                                        .font(GameTheme.buttonFont)
                                        .frame(width: 50, height: 50)
                                        .background(viewModel.selectedAnswers[viewModel.currentQuestionIndex] == alternativeID ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                
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
                            .frame(width: 500) // Ensures everything is aligned properly
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                // Character Icon (can be customized)
                Image(systemName: "questionmark.circle.fill") // Placeholder character icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.gameBlue)
                    .offset(x: -400)
                    .zIndex(1)
            }
            
            Spacer()
                       
            // Next Button to advance to next question
            HStack {
                Spacer()
                
                AnimatedCircleButton(
                    iconName: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill",
                    color: .gameLightBlue,
                    action: {
                        if viewModel.nextQuestion() {
                            currentPhase.next() // Move to next game phase if last question
                        }
                    }
                )
                .padding()
            }
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
            correctAnswer: 3
        ),
        Question(
            question: "Which planet is closest to the Sun?",
            alternatives: [1: "Earth", 2: "Venus", 3: "Mercury", 4: "Mars"],
            correctAnswer: 3
        ),
        Question(
            question: "Who developed the theory of relativity?",
            alternatives: [1: "Isaac Newton", 2: "Albert Einstein", 3: "Marie Curie", 4: "Nikola Tesla"],
            correctAnswer: 2
        )
    ]
    QuestionsView(viewModel: QuestionsViewModel(questions: sampleQuestions), currentPhase: $previewPhase)
}
