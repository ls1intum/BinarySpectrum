import SwiftUI

struct MiniGameIntroView: View {
    let title: String
    let characterImage: String
    let dialogues: [String]
    let onNext: () -> Void
    
    @State private var currentDialogueIndex = 0
    
    var body: some View {
        VStack {
            // Top Bar: Mini-game title & Info button
            HStack {
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.gameDarkBlue)
                
                Spacer()
                
                Button(action: {
                    // Handle info button action
                }) {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gameBlue)
                }
            }
            .padding()
            
            Spacer()
            
            // Main Content: Character & Dialogue
            HStack {
                // Character Image (Left)
                Image(characterImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
                
                // Dialogue Box (Right)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .frame(height: 200)
                    
                    Text(dialogues[currentDialogueIndex])
                        .font(.body)
                        .foregroundColor(.gameDarkBlue)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
                .frame(width: 250)
            }
            .padding()
            
            Spacer()
            
            // Bottom: Next Button
            HStack {
                Spacer()
                
                Button(action: {
                    if currentDialogueIndex < dialogues.count - 1 {
                        currentDialogueIndex += 1
                    } else {
                        onNext() // Move to the next screen
                    }
                }) {
                    Text(currentDialogueIndex < dialogues.count - 1 ? "Next" : "Start Game")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gameGreen))
                        .shadow(radius: 5)
                }
                .padding()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
    }
}

#Preview {
    MiniGameIntroView(
        title: "Logic Puzzle",
        characterImage: "character_robot",
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
