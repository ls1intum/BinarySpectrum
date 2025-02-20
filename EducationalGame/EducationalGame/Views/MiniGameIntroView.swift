import SwiftUI

struct MiniGameIntroView: View {
    let title: String
    let characterIcon: String
    let dialogues: [String]
    let onNext: () -> Void
    
    @State private var currentDialogueIndex = 0
    
    var body: some View {
        TopBarView(title: "game explanation") // TODO: remove
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
                    .font(.body)
                    .foregroundColor(.gameDarkBlue)
                    .padding(40)
                    .frame(width: 600, alignment: .leading)
                
                // Character Icon
                Image(systemName: characterIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.gameBlue)
                    .offset(x: -360)
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
                            onNext() // Move to the next screen
                        }
                    }
                )
                .padding()
            }
        }
        .frame(maxHeight: .infinity, alignment: .center) // Forces VStack to fill screen
        .ignoresSafeArea()
    }
}

#Preview {
    MiniGameIntroView(
        title: "Logic Puzzle",
        characterIcon: "lizard.fill",
        dialogues: [
            "Welcome to the Logic Puzzle mini-game!",
            "Here, you'll learn how to think step by step, just like a computer.",
            "Ready to begin? Let's go!"
        ],
        onNext: {
            // Navigate to the game screen
        }
    )
}
