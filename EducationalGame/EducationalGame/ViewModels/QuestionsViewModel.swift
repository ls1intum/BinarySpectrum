import SwiftUI

@Observable class QuestionsViewModel: ObservableObject {
    var questions: [Question]
    var selectedAnswers: [Int: Int] = [:] // Stores selected answer per question
    var correctAnswersCount: Int = 0 // Stores total correct answers
    var currentQuestionIndex: Int = 0 // Tracks current question
    var showExplanation: Bool = false // Controls explanation visibility
    var currentExplanation: String = "" // Stores current explanation
    var isAnswerCorrect: Bool = false // Tracks if current answer is correct
    
    // Store randomized order of alternatives for each question
    private var randomizedAlternativeKeys: [[Int]] = []
    
    init(questions: [Question]) {
        self.questions = questions
        
        // Initialize randomized alternative keys for each question
        randomizeAlternatives()
    }
    
    // Randomize the order of alternatives for all questions
    private func randomizeAlternatives() {
        randomizedAlternativeKeys = []
        
        for question in questions {
            // Get the sorted keys from the alternatives dictionary
            let keys = Array(question.alternatives.keys).sorted()
            
            // Create a shuffled copy of the keys
            var shuffledKeys = keys
            shuffledKeys.shuffle()
            
            // Store the shuffled keys for this question
            randomizedAlternativeKeys.append(shuffledKeys)
        }
    }
    
    // Get the randomized keys for the current question
    func getRandomizedKeys() -> [Int] {
        // If we haven't generated random keys yet or if the array is too short
        if randomizedAlternativeKeys.count <= currentQuestionIndex {
            // Get the sorted keys as a fallback
            let fallbackKeys = Array(questions[currentQuestionIndex].alternatives.keys).sorted()
            return fallbackKeys
        }
        
        return randomizedAlternativeKeys[currentQuestionIndex]
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
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            
            // If this question was already answered, immediately show its explanation
            updateStateForCurrentQuestion()
            
            return false
        }
        return true // Indicates all questions are completed
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
            isAnswerCorrect = false
        }
    }
    
    // Check if a specific question has been answered
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
