import SwiftUI

@Observable class QuestionsViewModel: ObservableObject {
    var questions: [Question]
    var selectedAnswers: [Int: Int] = [:] // Stores selected answer per question
    var correctAnswersCount: Int = 0 // Stores total correct answers
    var currentQuestionIndex: Int = 0 // Tracks current question
    var showExplanation: Bool = false // Controls explanation visibility
    var currentExplanation: String = "" // Stores current explanation
    var isAnswerCorrect: Bool = false // Tracks if current answer is correct
    
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
        isAnswerCorrect = selected == question.correctAnswer
        currentExplanation = question.explanation
        
        if isAnswerCorrect {
            correctAnswersCount += 1
        }
        
        showExplanation = true
    }
    
    func nextQuestion() -> Bool {
        showExplanation = false
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            return false
        }
        return true // Indicates all questions are completed
    }
    
    func getProgress() -> Double {
        return Double(correctAnswersCount) / Double(questions.count)
    }
}
