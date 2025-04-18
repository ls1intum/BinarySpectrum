import Foundation
import SwiftUICore

@Observable class BinaryGameViewModel: ObservableObject {
    // Current game phase
    private var _currentPhase: GamePhase = .intro
    var currentPhase: GamePhase {
        get { _currentPhase }
        set { _currentPhase = newValue }
    }
    
    // Game type identifier
    let gameType = "Binary Game"
    
    // For exploration view
    var selectedNumber: Int = 0
    
    let introDialogue = [
        "Welcome to the Binary Code Detective Academy!",
        "Did you know? Computers don't understand words or numbers the way we do. They only understand ON and OFF - or 1 and 0.",
        "This is called 'binary code', and it's the secret language that powers all technology!",
        "As a Binary Detective, you'll learn how to turn regular numbers into binary code, and decode binary back into numbers.",
        "This is a fundamental concept in computational thinking - breaking down information into its simplest form!"
    ]
    
    let practiceDialogue = [
        "Great exploration, Detective! You've discovered how binary numbers work.",
        "Binary is all about patterns and breaking down numbers into powers of 2: 1, 2, 4, 8, 16...",
        "This is a key computational thinking skill called 'decomposition' - breaking big problems into smaller parts!",
        "Now let's practice converting decimal numbers (what we use every day) into binary (what computers use).",
        "Remember: Each position represents a power of 2, starting from the right with 1, then 2, 4, 8, and so on."
    ]
    
    let introQuestions: [Question] = [
        Question(
            question: "Why do computers use binary code instead of regular numbers?",
            alternatives: [
                1: "Binary numbers look cooler in movies",
                2: "Electronics can easily represent two states (ON/OFF)",
                3: "Binary uses less electricity than decimal numbers",
                4: "Programmers prefer working with only two digits"
            ],
            correctAnswer: 2,
            explanation: "Computers use binary because electronic circuits can easily represent two states: ON (1) or OFF (0)."
        )
        // TODO: Add more questions
    ]
    
    // Binary Learning Properties
    let digitCount: Int = 4
    var binaryDigits: [String] = Array(repeating: "0", count: 4)
    var showAlert = false
    var alertMessage = ""
    var highlightCorrectBits = false
    var stepIndex = 0
    let targetNumber: Int = .random(in: 8...15)
    
    // Challenge Properties
    let challengeDigitCount: Int = 5
    var challengeBinaryDigits: [String] = Array(repeating: "0", count: 5)
    let challengeTargetNumber: Int = .random(in: 16...31)
    
    // Advanced Challenge Properties
    let advancedDigitCount: Int = 5
    let advancedTargetNumber: Int = .random(in: 5...31)
    var advancedBinaryDigits: [String] {
        String(advancedTargetNumber, radix: 2).paddingLeft(with: "0", toLength: advancedDigitCount).map { String($0) }
    }

    var userDecimalAnswer: String = ""
    
    var decimalValue: Int {
        return Int(binaryDigits.joined(), radix: 2) ?? 0
    }
    
    var challengeDecimalValue: Int {
        return Int(challengeBinaryDigits.joined(), radix: 2) ?? 0
    }
    
    var targetNumberBinary: [String] {
        String(targetNumber, radix: 2).paddingLeft(with: "0", toLength: digitCount).map { String($0) }
    }
    
    var challengeTargetNumberBinary: [String] {
        String(challengeTargetNumber, radix: 2).paddingLeft(with: "0", toLength: challengeDigitCount).map { String($0) }
    }
    
    // Complete a game stage and advance to next phase
    func completeGame(score: Int, percentage: Double) {
        // Record completion using the shared userViewModel
        sharedUserViewModel.completeMiniGame("\(gameType) - \(currentPhase.rawValue)", 
                                      score: score, 
                                      percentage: percentage)
        
        // Advance to next phase locally
        var nextPhase = self.currentPhase
        nextPhase.next(for: gameType)
        self._currentPhase = nextPhase
    }
    
    func checkAnswer() {
        if decimalValue == targetNumber {
            alertMessage = "✅ Great job! \(targetNumber) in binary is \(String(targetNumber, radix: 2))"
            showAlert = true
        } else {
            let difference = decimalValue - targetNumber
            if difference > 0 {
                alertMessage = "Your number is too large by \(difference). Try turning off some bits."
            } else {
                alertMessage = "Your number is too small by \(abs(difference)). Try turning on some bits."
            }
            showAlert = true
        }
    }
    
    func checkChallengeAnswer() {
        if challengeDecimalValue == challengeTargetNumber {
            alertMessage = "✅ Great job! \(challengeTargetNumber) in binary is \(String(challengeTargetNumber, radix: 2))"
            showAlert = true
        } else {
            let difference = challengeDecimalValue - challengeTargetNumber
            if difference > 0 {
                alertMessage = "Your number is too large by \(difference). Try turning off some bits."
            } else {
                alertMessage = "Your number is too small by \(abs(difference)). Try turning on some bits."
            }
            showAlert = true
        }
    }
    
    func checkAdvancedAnswer() {
        if let answer = Int(userDecimalAnswer), answer == advancedTargetNumber {
            alertMessage = "✅ Great job! \(advancedTargetNumber) in binary is \(String(advancedTargetNumber, radix: 2))"
            showAlert = true
        } else {
            let difference = (Int(userDecimalAnswer) ?? 0) - advancedTargetNumber
            if difference > 0 {
                alertMessage = "Your number is too large by \(difference). Try a smaller number."
            } else {
                alertMessage = "Your number is too small by \(abs(difference)). Try a larger number."
            }
            showAlert = true
        }
    }
    
    // Final Challenge Properties
    var birthDay: Int = 1
    var birthMonth: Int = 1
    var dayBinaryDigits: [String] = Array(repeating: "0", count: 5) // 1-31 requires 5 bits
    var monthBinaryDigits: [String] = Array(repeating: "0", count: 4) // 1-12 requires 4 bits
    
    var dayDecimalValue: Int {
        return Int(dayBinaryDigits.joined(), radix: 2) ?? 0
    }
    
    var monthDecimalValue: Int {
        return Int(monthBinaryDigits.joined(), radix: 2) ?? 0
    }
    
    var isDayValid: Bool {
        return dayDecimalValue >= 1 && dayDecimalValue <= 31
    }
    
    var isMonthValid: Bool {
        return monthDecimalValue >= 1 && monthDecimalValue <= 12
    }
    
    var isBirthdateValid: Bool {
        guard isMonthValid && isDayValid else { return false }
        let calendar = Calendar.current
        let components = DateComponents(year: 2000, month: monthDecimalValue, day: dayDecimalValue)
        return calendar.date(from: components) != nil
    }
    
    func checkBirthdateChallenge() {
        if isBirthdateValid {
            birthDay = dayDecimalValue
            birthMonth = monthDecimalValue
            alertMessage = "✅ Great job! Your binary armband shows your birthday: \(birthMonth)/\(birthDay)"
            showAlert = true
        } else {
            if !isDayValid {
                alertMessage = "Invalid day. Days should be between 1-31."
            } else if !isMonthValid {
                alertMessage = "Invalid month. Months should be between 1-12."
            } else {
                alertMessage = "Invalid date. Please check if this date exists in the calendar."
            }
            showAlert = true
        }
    }

    // Review Cards Content
    let reviewCards: [(title: String, content: String, example: String)] = [
        (
            title: "Binary Basics",
            content: "Binary is a base-2 number system that uses only two digits: 0 and 1. Each digit is called a 'bit'.",
            example: "101 = 1×4 + 0×2 + 1×1 = 5"
        ),
        (
            title: "Powers of 2",
            content: "Each position in a binary number represents a power of 2, starting from the right.",
            example: "8 4 2 1\n1 0 1 0 = 10"
        ),
        (
            title: "Binary to Decimal",
            content: "To convert binary to decimal, multiply each bit by its power of 2 and add the results.",
            example: "1101 = 1×8 + 1×4 + 0×2 + 1×1 = 13"
        ),
        (
            title: "Decimal to Binary",
            content: "To convert decimal to binary, find the largest power of 2 that fits, subtract it, and repeat.",
            example: "11 = 8 + 2 + 1 = 1011"
        ),
        (
            title: "Binary Armband",
            content: "You can represent dates in binary! Your armband shows your birthdate in binary form.",
            example: "Month: 4 bits (1-12)\nDay: 5 bits (1-31)"
        )
    ]
}
