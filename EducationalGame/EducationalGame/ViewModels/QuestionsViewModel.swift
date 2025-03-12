import SwiftUI

@Observable class QuestionsViewModel: ObservableObject {
    var questions: [Question]
    var selectedAnswers: [Int: Int] = [:] // Stores selected answer per question
    var correctAnswersCount: Int = 0 // Stores total correct answers
    var currentQuestionIndex: Int = 0 // Tracks current question
    
    init(questions: [Question]) {
        self.questions = questions
    }
    
    func selectAnswer(_ alternativeID: Int) {
        let questionIndex = currentQuestionIndex
        selectedAnswers[questionIndex] = alternativeID
        checkAnswer(selected: alternativeID)
    }
    
    func checkAnswer(selected: Int) {
        let question = questions[currentQuestionIndex]
        if selected == question.correctAnswer {
            correctAnswersCount += 1
        }
    }
    
    func nextQuestion() -> Bool {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            return false
        }
        return true // Indicates all questions are completed
    }
}
