import Foundation
import SwiftUI

@Observable class BinaryGameViewModel: ObservableObject {
    let gameType = "Binary Game"
    var currentPhase: GamePhase = .introDialogue
    
    // MARK: - State Structs
    
    struct ExplorationState {
        var selectedNumber: Int = 0
    }
    
    struct NoviceChallengeState {
        var digitCount: Int = 4
        var binaryDigits: [String] = Array(repeating: "0", count: 4)
        var targetNumber: Int = .random(in: 8...15)
        
        var decimalValue: Int {
            return Int(binaryDigits.joined(), radix: 2) ?? 0
        }
        
        var targetNumberBinary: [String] {
            String(targetNumber, radix: 2).paddingLeft(with: "0", toLength: digitCount).map { String($0) }
        }
        
        mutating func reset() {
            binaryDigits = Array(repeating: "0", count: digitCount)
            targetNumber = .random(in: 8...15)
        }
    }
    
    struct ApprenticeChallengeState {
        var digitCount: Int = 5
        var binaryDigits: [String] = Array(repeating: "0", count: 5)
        var targetNumber: Int = .random(in: 16...31)
        
        var decimalValue: Int {
            return Int(binaryDigits.joined(), radix: 2) ?? 0
        }
        
        var targetNumberBinary: [String] {
            String(targetNumber, radix: 2).paddingLeft(with: "0", toLength: digitCount).map { String($0) }
        }
        
        mutating func reset() {
            binaryDigits = Array(repeating: "0", count: digitCount)
            targetNumber = .random(in: 16...31)
        }
    }
    
    struct AdeptChallengeState {
        var digitCount: Int = 5
        var targetNumber: Int = .random(in: 5...31)
        var userDecimalAnswer: String = ""
        
        var binaryDigits: [String] {
            String(targetNumber, radix: 2).paddingLeft(with: "0", toLength: digitCount).map { String($0) }
        }
        
        mutating func reset() {
            targetNumber = .random(in: 5...31)
            userDecimalAnswer = ""
        }
    }
    
    struct ExpertChallengeState {
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
        
        mutating func reset() {
            dayBinaryDigits = Array(repeating: "0", count: 5)
            monthBinaryDigits = Array(repeating: "0", count: 4)
        }
    }
    
    // MARK: - State Properties
    
    var explorationState = ExplorationState()
    var noviceState = NoviceChallengeState()
    var apprenticeState = ApprenticeChallengeState()
    var adeptState = AdeptChallengeState()
    var expertState = ExpertChallengeState()
    
    // MARK: - UI State
    
    var showHint = false
    var isCorrect = false
    var hintMessage: LocalizedStringResource = ""
    var alertMessage: LocalizedStringResource = ""
    
    // MARK: - Game Content
    
    var introDialogue: [LocalizedStringResource] { GameConstants.BinaryGameContent.introDialogue }
    var practiceDialogue: [LocalizedStringResource] { GameConstants.BinaryGameContent.practiceDialogue }
    var finalDialogue: [LocalizedStringResource] { GameConstants.BinaryGameContent.finalDialogue }
    var introQuestions: [Question] { GameConstants.BinaryGameContent.introQuestions }
    var reviewCards: [ReviewCard] { GameConstants.BinaryGameContent.reviewCards }
    var rewardMessage: LocalizedStringResource { GameConstants.BinaryGameContent.rewardMessage }
    
    // User info
    let favoriteColor: Color = .gamePink // TODO: get from userviewmodel
    
    // MARK: - Game Logic
    
    func hideHint() {
        showHint = false
        if isCorrect {
            completeGame(score: 100, percentage: 1.0)
        }
    }
    
    func checkNoviceAnswer() {
        if noviceState.decimalValue == noviceState.targetNumber {
            isCorrect = true
            hintMessage = "Great job! \(noviceState.targetNumber) in binary is \(String(noviceState.targetNumber, radix: 2))"
        } else {
            isCorrect = false
            let difference = noviceState.decimalValue - noviceState.targetNumber
            if difference > 0 {
                hintMessage = "Your number is too large by \(difference). Try turning off some bits."
            } else {
                hintMessage = "Your number is too small by \(abs(difference)). Try turning on some bits."
            }
        }
        showHint = true
    }
    
    func checkApprenticeAnswer() {
        if apprenticeState.decimalValue == apprenticeState.targetNumber {
            isCorrect = true
            hintMessage = "Great job! \(apprenticeState.targetNumber) in binary is \(String(apprenticeState.targetNumber, radix: 2))"
        } else {
            isCorrect = false
            let difference = apprenticeState.decimalValue - apprenticeState.targetNumber
            if difference > 0 {
                hintMessage = "Your number is too large by \(difference). Try turning off some bits."
            } else {
                hintMessage = "Your number is too small by \(abs(difference)). Try turning on some bits."
            }
        }
        showHint = true
    }
    
    func checkAdeptAnswer() {
        if let answer = Int(adeptState.userDecimalAnswer), answer == adeptState.targetNumber {
            isCorrect = true
            hintMessage = "Great job! \(adeptState.targetNumber) in binary is \(String(adeptState.targetNumber, radix: 2))"
        } else {
            isCorrect = false
            let difference = (Int(adeptState.userDecimalAnswer) ?? 0) - adeptState.targetNumber
            if difference > 0 {
                hintMessage = "Your number is too large by \(difference). Try a smaller number."
            } else {
                hintMessage = "Your number is too small by \(abs(difference)). Try a larger number."
            }
        }
        showHint = true
    }
    
    func checkBirthdateChallenge() {
        if expertState.isBirthdateValid {
            isCorrect = true
            hintMessage = "Great job! Your binary armband shows your birthday: \(expertState.dayDecimalValue).\(expertState.monthDecimalValue)."
        } else {
            isCorrect = false
            if !expertState.isDayValid {
                hintMessage = "Invalid day. Days should be between 1-31."
            } else if !expertState.isMonthValid {
                hintMessage = "Invalid month. Months should be between 1-12."
            } else {
                hintMessage = "Invalid date. Please check if this date exists in the calendar."
            }
        }
        showHint = true
    }
    
    func completeGame(score: Int, percentage: Double) {
        // Record completion using the shared userViewModel
        sharedUserViewModel.completeMiniGame("\(gameType) - \(currentPhase.rawValue)",
                                             score: score,
                                             percentage: percentage)
        switch currentPhase {
        case .noviceChallenge:
            SoundService.shared.playSound(.levelUp1)
        case .apprenticeChallenge:
            SoundService.shared.playSound(.levelUp2)
        case .adeptChallenge:
            SoundService.shared.playSound(.levelUp3)
        case .expertChallenge:
            SoundService.shared.playSound(.levelUp4)
        case .review:
            SoundService.shared.playSound(.badge)
        default:
            break
        }
        
        currentPhase.next(for: gameType)
    }
    
    func nextPhase() {
        currentPhase.next(for: gameType)
    }
    
    func resetGame() {
        currentPhase = .introDialogue
        explorationState = ExplorationState()
        noviceState.reset()
        apprenticeState.reset()
        adeptState.reset()
        expertState.reset()
        showHint = false
        isCorrect = false
        hintMessage = ""
        alertMessage = ""
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
        resetGame()
    }
}
