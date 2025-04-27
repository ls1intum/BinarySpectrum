import SwiftUI

struct DialogueView: View {
    let personaImage: String
    let color: Color
    let dialogues: [String]
    let gameType: String
    @Binding var currentPhase: GamePhase
    
    @State private var currentDialogueIndex = 0
    @State private var opacity = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Text Box
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameGray)
                    .shadow(radius: 5)
                    .frame(width: 600, height: 300)
                
                // Text Inside Box
                Text(dialogues[currentDialogueIndex])
                    .font(GameTheme.bodyFont)
                    .foregroundColor(.gameDarkBlue)
                    .padding(40)
                    .frame(width: 600, alignment: .leading)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            opacity = 1.0
                        }
                        // withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)) {
                        //    scale = 1.0
                        // }
                    }
                
                // Character
                Image(personaImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.gameBlue)
                    .offset(x: -400)
                    .zIndex(1)
            }
            
            Spacer()
            
            // Navigation Buttons at the Bottom
            HStack {
                // Back Button (only visible if not on first dialogue)
                if currentDialogueIndex > 0 {
                    AnimatedCircleButton(
                        iconName: "arrow.left.circle.fill",
                        color: .gameGray,
                        action: {
                            if currentDialogueIndex > 0 {
                                currentDialogueIndex -= 1
                            }
                        }
                    )
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: currentDialogueIndex)
                } else {
                    // Empty space to maintain layout when back button is not visible
                    Spacer()
                        .frame(width: 70)
                }
                
                // Page indicator
                Text("\(currentDialogueIndex + 1) / \(dialogues.count)")
                    .font(GameTheme.bodyFont)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Next Button
                AnimatedCircleButton(
                    iconName: currentDialogueIndex < dialogues.count - 1 ? "arrow.right.circle.fill" : "play.fill",
                    color: color,
                    action: {
                        if currentDialogueIndex < dialogues.count - 1 {
                            currentDialogueIndex += 1
                        } else {
                            currentPhase.next(for: gameType)
                        }
                    }
                )
                .padding()
            }
            .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @Previewable @State var previewPhase = GamePhase.challenges // Sample mutable state
    
    DialogueView(
        personaImage: "Persona1",
        color: .gameGreen,
        dialogues: ["Welcome to our educational game! Here you'll learn important computational thinking concepts.", "Each mini-game teaches different skills like binary representation, pixel art, and color theory.", "Navigate through the dialogue using the buttons at the bottom."],
        gameType: "Binary Game",
        currentPhase: $previewPhase // Pass as a Binding
    )
}
