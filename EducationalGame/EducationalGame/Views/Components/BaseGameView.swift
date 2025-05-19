import SwiftUI

/// A base view for all mini-games that can handle challenge parameters
struct BaseGameView<Content: View>: View {
    @EnvironmentObject private var navigationState: NavigationState
    @Environment(\.dismiss) private var dismiss
    @State private var challengeParams: ChallengeParams?
    let content: Content
    
    // Challenge view properties
    var instruction: LocalizedStringResource?
    var showCheckButton: Bool = false
    var onCheck: (() -> Void)?
    var gameColor: Color?
    
    init(
        instruction: LocalizedStringResource? = nil,
        showCheckButton: Bool = false,
        onCheck: (() -> Void)? = nil,
        gameColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.instruction = instruction
        self.showCheckButton = showCheckButton
        self.onCheck = onCheck
        self.gameColor = gameColor
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if instruction != nil {
                // Challenge view layout
                ZStack {
                    VStack(spacing: 20) {
                        InstructionBar(text: instruction!)
                            .padding(.top, 32)
                        Spacer()
                        
                        content
                        
                        Spacer()
                    }
                    if showCheckButton {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                AnimatedCircleButton(
                                    iconName: "checkmark.circle.fill",
                                    color: gameColor ?? .gamePurple,
                                    action: {
                                        if let onCheck = onCheck {
                                            onCheck()
                                        }
                                    }
                                )
                                .padding(.trailing, 20)
                            }
                        }
                    }
                }
            } else {
                // Regular game view layout
                content
            }
        }
        .onAppear {
            // Check if we have challenge parameters passed from the environment
            if let params = challengeParams, params.returnToChallenges {
                print("Challenge mode: \(params.phase.rawValue) for game \(params.miniGameId)")
            }
        }
        .environment(\.challengeParams) { params in
            self.challengeParams = params
        }
    }
    
    private func handleBackAction() {
        HapticService.shared.play(.light)
        
        // If this is a challenge and we should return to challenges
        if let params = challengeParams, params.returnToChallenges {
            navigationState.returnToChallengesView()
        } else {
            // Normal back navigation
            dismiss()
            if navigationState.canGoBack {
                navigationState.goBack()
            }
        }
    }
}

/// Environment key getter with callback for challenge parameters
extension EnvironmentValues {
    struct ChallengeParamsKey: EnvironmentKey {
        static let defaultValue: ((ChallengeParams) -> Void)? = nil
    }
    
    var challengeParams: ((ChallengeParams) -> Void)? {
        get { self[ChallengeParamsKey.self] }
        set { self[ChallengeParamsKey.self] = newValue }
    }
}
