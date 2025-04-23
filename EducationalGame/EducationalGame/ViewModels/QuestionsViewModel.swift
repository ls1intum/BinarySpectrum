import SwiftUI
import Foundation

class QuestionsViewModel: ObservableObject {
    @Published var questions: [Question]
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [Int: Int] = [:]
    @Published var correctAnswersCount: Int = 0
    var showExplanation: Bool = false
    var currentExplanation: String = ""
    var isAnswerCorrect: Bool = false
    
    // Randomized alternatives to avoid memorization
    private var alternativeMap: [Int: [Int]] = [:]
    
    init(questions: [Question]) {
        self.questions = questions
        // Initialize randomized alternative keys for each question
        randomizeAlternatives()
        
        // Listen for reset notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetGameState),
            name: NSNotification.Name("ResetGameProgress"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func resetGameState() {
        // Reset the quiz state
        currentQuestionIndex = 0
        selectedAnswers = [:]
        correctAnswersCount = 0
        showExplanation = false
        currentExplanation = ""
        isAnswerCorrect = false
        randomizeAlternatives() // Randomize again for a fresh experience
    }
    
    // Randomize the order of alternatives for all questions
    private func randomizeAlternatives() {
        alternativeMap.removeAll()
        
        for (index, question) in questions.enumerated() {
            // Get the keys from the alternatives dictionary
            let keys = Array(question.alternatives.keys)
            
            // Create a shuffled copy of the keys
            var shuffledKeys = keys
            shuffledKeys.shuffle()
            
            // Store the shuffled keys for this question
            alternativeMap[index] = shuffledKeys
        }
    }
    
    // Get the current question's randomized alternative keys
    func getRandomizedKeys() -> [Int] {
        guard currentQuestionIndex < questions.count else { return [] }
        
        // If we have stored randomized keys for this question, use them
        if let randomKeys = alternativeMap[currentQuestionIndex] {
            return randomKeys
        }
        
        // Otherwise, fall back to the natural order of keys
        return Array(questions[currentQuestionIndex].alternatives.keys).sorted()
    }
    
    // Handle selection of an answer
    func selectAnswer(_ alternativeID: Int) {
        guard currentQuestionIndex < questions.count else { return }
        
        let question = questions[currentQuestionIndex]
        
        // Store the selected answer
        selectedAnswers[currentQuestionIndex] = alternativeID
        
        // Check if the answer is correct
        isAnswerCorrect = (alternativeID == question.correctAnswer)
        
        // Update correct answer count if this is the first time answering correctly
        if isAnswerCorrect && selectedAnswers[currentQuestionIndex] == alternativeID {
            correctAnswersCount += 1
        }
        
        // Show explanation
        currentExplanation = questions[currentQuestionIndex].explanation
        showExplanation = true
    }
    
    // Move to the next question
    func nextQuestion() -> Bool {
        // Reset the explanation state
        showExplanation = false
        currentExplanation = ""
        
        // If we're at the last question, return true to indicate completion
        if currentQuestionIndex >= questions.count - 1 {
            return true
        }
        
        // Otherwise, go to the next question
        currentQuestionIndex += 1
        return false
    }
    
    // Go back to the previous question
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            
            // Update the state for the question we're navigating to
            updateStateForCurrentQuestion()
        }
    }
    
    // Update the state for the current question (explanation, correctness, etc.)
    private func updateStateForCurrentQuestion() {
        // If this question was already answered, show its explanation
        if let selectedAnswer = selectedAnswers[currentQuestionIndex] {
            let question = questions[currentQuestionIndex]
            isAnswerCorrect = selectedAnswer == question.correctAnswer
            currentExplanation = question.explanation
            showExplanation = true
        } else {
            // If not answered yet, hide the explanation
            showExplanation = false
            currentExplanation = ""
        }
    }
    
    // Check if a question has been answered
    func isQuestionAnswered(_ index: Int) -> Bool {
        return selectedAnswers[index] != nil
    }
    
    // Check if the current question has been answered
    func isCurrentQuestionAnswered() -> Bool {
        return isQuestionAnswered(currentQuestionIndex)
    }
    
    // Check if we can navigate to the next question
    func canNavigateToNextQuestion() -> Bool {
        // If current question is answered, we can always move forward
        if isCurrentQuestionAnswered() {
            return true
        }
        
        // If next question has already been answered, we can also move forward
        if currentQuestionIndex < questions.count - 1 && isQuestionAnswered(currentQuestionIndex + 1) {
            return true
        }
        
        return false
    }
    
    func getProgress() -> Double {
        return Double(correctAnswersCount) / Double(questions.count)
    }
}
