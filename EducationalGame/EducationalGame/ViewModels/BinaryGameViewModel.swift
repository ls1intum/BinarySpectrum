import Foundation
import SwiftUICore

@Observable class BinaryGameViewModel: ObservableObject {
    var currentPhase = GamePhase.allCases[0]
    let introDialogue = ["Welcome to Binary Game!", "You are a binary code detective.", "Your mission is to decode the binary code."] //TODO: improve intro texts
    
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
