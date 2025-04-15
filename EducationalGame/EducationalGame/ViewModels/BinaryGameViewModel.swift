import Foundation
import SwiftUICore

@Observable class BinaryGameViewModel: ObservableObject {
    var currentPhase = GamePhase.allCases[0]
    let introDialogue = ["Welcome to Binary Game!", "You are a binary code detective.", "Your mission is to decode the binary code."] // TODO: improve intro texts
    let practiceDialogue = [
        "Great job exploring binary numbers! Now it's time to practice what you've learned. You'll need to convert decimal numbers to binary by toggling the bits.",
        "Remember: Each position represents a power of 2, starting from the right. Let's begin!"
    ]
    let introQuestions: [Question] = [
        Question(
            question: "Which number system do computers use for basic operations?",
            alternatives: [
                1: "Decimal (0-9)",
                2: "Binary (0 & 1)",
                3: "Hexadecimal (0-F)"
            ],
            correctAnswer: 2,
            explanation: "Computers use the binary number system (base-2) for their basic operations because it's easier to represent with electronic circuits. A 0 can be represented by no voltage, and a 1 by the presence of voltage."
        ),
        Question(
            question: "How would you write the number 5 in binary?",
            alternatives: [
                1: "101",
                2: "110",
                3: "111"
            ],
            correctAnswer: 1,
            explanation: "The binary number 101 represents 5 in decimal. Here's how: (1 × 2²) + (0 × 2¹) + (1 × 2⁰) = 4 + 0 + 1 = 5. Each digit in binary represents a power of 2, starting from the right."
        ),
        Question(
            question: "What is the maximum number you can represent with 4 binary digits?",
            alternatives: [
                1: "8",
                2: "15",
                3: "16"
            ],
            correctAnswer: 2,
            explanation: "With 4 binary digits, you can represent numbers from 0 to 15. This is because 2⁴ = 16 possible combinations (including 0). The maximum value is 1111 in binary, which equals 15 in decimal."
        ),
        Question(
            question: "Why is binary important in computing?",
            alternatives: [
                1: "It's easier for humans to understand",
                2: "It matches how computer hardware works",
                3: "It's more efficient for calculations"
            ],
            correctAnswer: 2,
            explanation: "Binary is fundamental to computing because it matches how computer hardware works. Transistors, the basic building blocks of computers, can only be in two states: on (1) or off (0). This makes binary a natural choice for representing data in computers."
        ),
        Question(
            question: "How many bits are in a byte?",
            alternatives: [
                1: "4 bits",
                2: "8 bits",
                3: "16 bits"
            ],
            correctAnswer: 2,
            explanation: "A byte consists of 8 bits. This is a standard unit of digital information in computing. Each bit can be either 0 or 1, so a byte can represent 256 different values (2⁸)."
        )
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
        // Additional validation for days in each month
        guard isDayValid && isMonthValid else { return false }
        
        // February
        if monthDecimalValue == 2 && dayDecimalValue > 29 {
            return false
        }
        // April, June, September, November (30 days)
        if [4, 6, 9, 11].contains(monthDecimalValue) && dayDecimalValue > 30 {
            return false
        }
        
        return true
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
}

extension String {
    func paddingLeft(with character: Character, toLength: Int) -> String {
        return String(repeating: String(character), count: max(0, toLength - count)) + self
    }
}
