import SwiftUI

struct DialogueView: View {
    let characterIcon: String
    let dialogues: [String]
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
                    .frame(width: 660, height: 450)
                
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
                
                // Character Icon
                Image(systemName: characterIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.gameBlue)
                    .offset(x: -400)
                    .zIndex(1)
            }
            
            Spacer()
            
            // Next Button at the Bottom Right
            HStack {
                Spacer()
                
                AnimatedCircleButton(
                    iconName: currentDialogueIndex < dialogues.count - 1 ? "arrow.right.circle.fill" : "play.fill",
                    color: .gameLightBlue,
                    action: {
                        if currentDialogueIndex < dialogues.count - 1 {
                            currentDialogueIndex += 1
                        } else {
                            currentPhase.next()
                        }
                    }
                )
                .padding()
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    @State var previewPhase = GamePhase.challenges // Sample mutable state
    
    DialogueView(
        characterIcon: "person.circle",
        dialogues: ["hi alwhfsa", "hello"],
        currentPhase: $previewPhase // Pass as a Binding
    )
}
