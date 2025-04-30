import Foundation
import SwiftUI

@Observable class BinaryGameViewModel: ObservableObject {
    let gameType = "Binary Game"
    var currentPhase: GamePhase = .intro
    
    // User info
    let favoriteColor: Color = .gamePink // TODO: get from userviewmodel
    
    // Use data from GameConstants.BinaryGameContent
    var introDialogue: [String] { GameConstants.BinaryGameContent.introDialogue }
    var practiceDialogue: [String] { GameConstants.BinaryGameContent.practiceDialogue }
    var finalDialogue: [String] { GameConstants.BinaryGameContent.finalDialogue }
    var introQuestions: [Question] { GameConstants.BinaryGameContent.introQuestions }
    var reviewCards: [ReviewCard] { GameConstants.BinaryGameContent.reviewCards }
    var rewardMessage: String { GameConstants.BinaryGameContent.rewardMessage }
   
    // For exploration view
    var selectedNumber: Int = 0
    
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
        
        var nextPhase = currentPhase
        nextPhase.next(for: gameType)
        _currentPhase = nextPhase
    }
    
    func nextPhase() {
        currentPhase.next(for: gameType)
    }
    
    func checkAnswer() {
        if decimalValue == targetNumber {
            alertMessage = "Great job! \(targetNumber) in binary is \(String(targetNumber, radix: 2))"
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
            alertMessage = "Great job! \(challengeTargetNumber) in binary is \(String(challengeTargetNumber, radix: 2))"
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
            alertMessage = "Great job! \(advancedTargetNumber) in binary is \(String(advancedTargetNumber, radix: 2))"
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

    var monthStringValue: LocalizedStringResource {
        if monthDecimalValue == 1 {
            return .init("of January")
        } else if monthDecimalValue == 2 {
            return .init("of February")
        } else if monthDecimalValue == 3 {
            return .init("of March")
        } else if monthDecimalValue == 4 {
            return .init("of April")
        } else if monthDecimalValue == 5 {
            return .init("of May")
        } else if monthDecimalValue == 6 {
            return .init("of June")
        } else if monthDecimalValue == 7 {
            return .init("of July")
        } else if monthDecimalValue == 8 {
            return .init("of August")
        } else if monthDecimalValue == 9 {
            return .init("of September")
        } else if monthDecimalValue == 10 {
            return .init("of October")
        } else if monthDecimalValue == 11 {
            return .init("of November")
        } else if monthDecimalValue == 12 {
            return .init("of December")
        } else {
            return " "
        }
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
            alertMessage = "Great job! Your binary armband shows your birthday: \(birthDay).\(birthMonth)."
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

    init() {
        // Initialize game state
        
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
        currentPhase = .intro
        // TODO: totally reset
        userDecimalAnswer = ""
    }
}
