import Foundation
import SwiftUICore

@Observable class BinaryGameViewModel: ObservableObject {
    var currentPhase = GamePhase.allCases[0]
    let introDialogue = ["Welcome to Binary Game!", "You are a binary code detective.", "Your mission is to decode the binary code."] //TODO: improve intro texts
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
    var showHint = false
    var highlightCorrectBits = false
    var stepIndex = 0
    var instructionText = LocalizedStringResource("")
    let targetNumber: Int = Int.random(in: 3...15)
    
    var decimalValue: Int {
        return Int(binaryDigits.joined(), radix: 2) ?? 0
    }
    
    var targetNumberBinary: [String] {
        String(targetNumber, radix: 2).paddingLeft(with: "0", toLength: digitCount).map { String($0) }
    }
    
    func checkAnswer() {
        if decimalValue == targetNumber {
            withAnimation {
                showHint = true
            }
        } else {
            showHint = false
            startStepByStepExplanation()
        }
    }
    
    func startStepByStepExplanation() {
        stepIndex = 0
        updateInstruction()
    }
    
    private func updateInstruction() {
        guard stepIndex < digitCount else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.instructionText = "Step \(self.stepIndex + 1): Set bit \(self.digitCount - self.stepIndex - 1) to \(self.targetNumberBinary[self.stepIndex])"
                self.binaryDigits[self.stepIndex] = self.targetNumberBinary[self.stepIndex]
            }
            self.stepIndex += 1
            self.updateInstruction()
        }
    }

}
extension String {
    func paddingLeft(with character: Character, toLength: Int) -> String {
        return String(repeating: String(character), count: max(0, toLength - self.count)) + self
    }
}
