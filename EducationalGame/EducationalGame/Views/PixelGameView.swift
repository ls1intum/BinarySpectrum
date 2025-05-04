import SwiftUI

struct PixelGameView: View {
    @Bindable var viewModel: PixelGameViewModel
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    init(viewModel: PixelGameViewModel = PixelGameViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer().frame(height: 90)
                currentPhaseView
            }
            TopBar(title: GameConstants.miniGames[1].name, color: GameConstants.miniGames[1].color)
                    
            if viewModel.showHint {
                InfoPopup(
                    title: viewModel.isCorrect ? "Correct!" : "Try Again",
                    message: viewModel.hintMessage,
                    buttonTitle: viewModel.isCorrect ? "Continue" : "OK",
                    onButtonTap: {
                        viewModel.hideHint()
                    }
                )
                .edgesIgnoringSafeArea(.all)
                .zIndex(10)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    private var currentPhaseView: some View {
        switch viewModel.currentPhase {
        case .introDialogue, .tutorialDialogue, .lastDialogue:
            DialogueView(
                personaImage: GameConstants.miniGames[1].personaImage,
                color: GameConstants.miniGames[1].color,
                dialogues: dialogueContent,
                gameType: viewModel.gameType,
                currentPhase: $viewModel.currentPhase
            )
        case .questions:
            QuestionsView(
                questions: viewModel.introQuestions,
                currentPhase: $viewModel.currentPhase,
                color: GameConstants.miniGames[1].color,
                gameType: viewModel.gameType
            )
        case .exploration:
            PixelExplorationView(viewModel: viewModel)
        case .noviceChallenge:
            PixelDecodingView(viewModel: viewModel)
        case .apprenticeChallenge:
            PixelEncodingView(viewModel: viewModel)
        case .adeptChallenge:
            PixelAdeptChallengeView(viewModel: viewModel)
        case .expertChallenge:
            PixelFinalChallengeView(viewModel: viewModel)
        case .review:
            ReviewView(
                title: "Pixel Images",
                items: viewModel.reviewCards.map { card in
                    ReviewItem(
                        title: card.title,
                        content: card.content,
                        example: card.example
                    )
                },
                color: GameConstants.miniGames[1].color,
                onCompletion: {
                    viewModel.completeGame(score: 50, percentage: 1.0)
                }
            )
        case .reward:
            RewardView(miniGameIndex: 1, message: viewModel.rewardMessage)
                .environmentObject(navigationState)
                .environmentObject(userViewModel)
        }
    }
    
    private var dialogueContent: [LocalizedStringResource] {
        switch viewModel.currentPhase {
        case .introDialogue: return viewModel.introDialogue
        case .tutorialDialogue: return viewModel.secondDialogue
        case .lastDialogue: return viewModel.finalDialogue
        default: return []
        }
    }
}

// MARK: - Base Views

struct PixelChallengeBaseView<Content: View>: View {
    @Bindable var viewModel: PixelGameViewModel
    let instruction: LocalizedStringResource
    let content: Content
    let showCheckButton: Bool
    let onCheck: () -> Void
    
    init(
        viewModel: PixelGameViewModel,
        instruction: LocalizedStringResource,
        showCheckButton: Bool = true,
        onCheck: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.viewModel = viewModel
        self.instruction = instruction
        self.showCheckButton = showCheckButton
        self.onCheck = onCheck
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                InstructionBar(text: instruction)
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
                            color: GameConstants.miniGames[1].color,
                            action: {
                                // Show info popup with appropriate message based on the check
                                viewModel.showHint = true
                                onCheck()
                            }
                        )
                        .padding(.trailing, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Challenge Views

struct PixelExplorationView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Create your own pixel art by tapping the grid squares",
            showCheckButton: true,
            onCheck: {
                viewModel.showBinaryCompletion()
            }
        ) {
            PixelGridView(
                viewModel: viewModel,
                showBinary: false
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(20)
        }
    }
}

struct PixelDecodingView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Decode the image by tapping the grid squares according to the binary code. 1 = black, 0 = white.",
            onCheck: { viewModel.checkAnswer() }
        ) {
            HStack(alignment: .center, spacing: 100) {
                // For 8x8 code - size fits exactly the content
                BinaryCodeView(code: viewModel.formattedCode, size: 8)
                    .frame(width: 180, height: 180)
                
                PixelGridView(
                    viewModel: viewModel,
                    showBinary: false
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding()
            .onAppear {
                // Load a new random art each time
                viewModel.setupDecodingChallenge()
            }
        }
    }
}

struct PixelEncodingView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Write the binary code for this image.\n Remember: 1 for black pixels, 0 for white pixels.",
            onCheck: { viewModel.checkBinaryEncoding() }
        ) {
            HStack(alignment: .center, spacing: 100) {
                PixelGridView(
                    viewModel: viewModel,
                    showBinary: false,
                    fixedCells: viewModel.encodingState.encodingChallengeGrid
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                BinaryInputView(text: $viewModel.encodingState.playerBinaryCode)
                    .frame(width: 250)
            }
            .padding()
            .onAppear {
                // Load a random art different from the decoding challenge
                viewModel.setupEncodingChallenge()
            }
        }
    }
}

struct PixelAdeptChallengeView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Decode this 16x16 image from binary code. 1 = black, 0 = white.",
            onCheck: { viewModel.checkAdeptAnswer() }
        ) {
            HStack(alignment: .center, spacing: 80) {
                // For 16x16 code - wider to fit a full row, with scrolling
                BinaryCodeView(code: viewModel.adeptState.formattedBinaryCode, size: 16)
                    .frame(width: 380, height: 300)
                
                PixelGridView(
                    viewModel: viewModel,
                    showBinary: false
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding()
        }
        .onAppear {
            // Initialize 16x16 grid with a random art challenge
            viewModel.setupAdeptChallenge()
        }
    }
}

struct PixelFinalChallengeView: View {
    @Bindable var viewModel: PixelGameViewModel
    @State private var gridSize: Int = 8
    
    // Function to calculate container size based on grid size
    private func containerSize(for gridSize: Int) -> CGFloat {
        let cellSize = gridSize == 8 ? 40.0 : 26.0
        let spacing = 0.5
        return CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing + 32 // Add padding
    }
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Create your own pixel art, compress it and name it!",
            onCheck: {
                // Setup success message for completion
                viewModel.isCorrect = true
                viewModel.hintMessage = "Congratulations! You've completed the Pixel Art challenges.\n\nYour final art has been saved, and you've learned how computers represent and compress images."
                viewModel.showHint = true
            }
        ) {
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    // Fixed-size container to prevent layout shifts
                    ZStack(alignment: .center) {
                        // Invisible placeholder to maintain size - always as large as the 16x16 grid would be
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: containerSize(for: 16), height: containerSize(for: 16))
                        
                        // Actual grid centered in the container
                        PixelGridView(
                            viewModel: viewModel,
                            showBinary: false
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Grid Size:")
                                .font(GameTheme.captionFont)
                                .foregroundColor(.gameBlack)
                            
                            Picker("", selection: $gridSize) {
                                Text("8×8").tag(8)
                                Text("16×16").tag(16)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                            .onChange(of: gridSize) { _, newSize in
                                viewModel.updateGridSize(newSize)
                            }
                        }
                        Button(action: {
                            viewModel.compressCurrentArt()
                        }) {
                            Label("Compress Image", systemImage: "arrow.down.doc")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.gameGreen.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        ScrollView {
                            if viewModel.compressionText.isEmpty {
                                Text("Compress your image to see its run-length encoding")
                                    .font(GameTheme.captionFont)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text(viewModel.compressionText)
                                    .font(.system(.body, design: .monospaced))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(height: 150) // Fixed height
                        .background(Color.gameGreen.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gameGreen.opacity(0.8), lineWidth: 3)
                        )
                        .cornerRadius(10)
                        
                        TextField("Name your pixel art", text: $viewModel.artName)
                            .font(GameTheme.bodyFont)
                            .padding(10)
                            .background(Color.gameRed.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gameRed.opacity(0.8), lineWidth: 2)
                            )
                            .autocorrectionDisabled(true)
                            .onSubmit {
                                // Auto-save when user presses return
                                if !viewModel.artName.isEmpty {
                                    viewModel.saveArt()
                                }
                            }
                    }
                    .frame(width: 300)
                }
            }
            .padding()
        }
        .onAppear {
            // Initialize with current grid size
            gridSize = viewModel.gridState.gridSize
        }
    }
}

// MARK: - Component Views

struct PixelGridView: View {
    @Bindable var viewModel: PixelGameViewModel
    let showBinary: Bool
    var fixedCells: Set<Int>? = nil
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(spacing: 0.5) {
                ForEach(0 ..< viewModel.gridState.gridSize, id: \.self) { row in
                    HStack(spacing: 0.5) {
                        ForEach(0 ..< viewModel.gridState.gridSize, id: \.self) { col in
                            let index = row * viewModel.gridState.gridSize + col
                            PixelCell(
                                isBlack: fixedCells?.contains(index) ?? viewModel.gridState.blackCells.contains(index),
                                showBinary: showBinary,
                                size: viewModel.gridState.cellSize,
                                onTap: fixedCells == nil ? { viewModel.toggleCell(index) } : nil
                            )
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: CGFloat(viewModel.gridState.gridSize) * viewModel.gridState.cellSize + CGFloat(viewModel.gridState.gridSize - 1) * 0.5 + 16,
               height: CGFloat(viewModel.gridState.gridSize) * viewModel.gridState.cellSize + CGFloat(viewModel.gridState.gridSize - 1) * 0.5 + 16)
    }
}

struct PixelCell: View {
    let isBlack: Bool
    let showBinary: Bool
    let size: CGFloat
    let onTap: (() -> Void)?
    
    @State private var animationState: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isBlack ? Color.gameBlack : Color.gameWhite)
                .frame(width: size, height: size)
                // Remove border to allow custom spacing in VStack/HStack
                .shadow(color: isBlack ? .black.opacity(0.5) : .black.opacity(0.1), radius: isBlack ? 2 : 1, x: 0, y: isBlack ? 2 : 1)
                .scaleEffect(animationState ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animationState)
                .overlay(
                    Rectangle()
                        .stroke(isBlack ? .black.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: isBlack ? 2 : 0.5)
                        .opacity(animationState ? 1.0 : 0)
                )
            
            if showBinary {
                Text(isBlack ? "1" : "0")
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundColor(isBlack ? .gameWhite : .gray)
                    .animation(.easeInOut(duration: 0.2), value: isBlack)
            }
            
            // Flash effect when changing state
            if animationState {
                Circle()
                    .fill(isBlack ? Color.white.opacity(0.3) : Color.black.opacity(0.2))
                    .scaleEffect(animationState ? 1.5 : 0.2)
                    .opacity(animationState ? 0 : 0.7)
                    .animation(.easeOut(duration: 0.4), value: animationState)
            }
        }
        .onChange(of: isBlack) { _, _ in
            // Trigger animation when isBlack changes
            animationState = true
            // Reset animation state after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animationState = false
            }
        }
        .onTapGesture {
            withAnimation {
                onTap?()
            }
        }
    }
}

struct BinaryCodeView: View {
    let code: String
    let size: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if size == 8 {
                Text(code)
                    .font(.system(.title2, design: .monospaced))
                    .padding(10)
                    .fixedSize(horizontal: true, vertical: true)
            } else {
                ScrollView([.vertical]) {
                    Text(code)
                        .font(.system(.title3, design: .monospaced))
                        .padding(10)
                        .fixedSize(horizontal: true, vertical: true)
                }
                .scrollIndicators(.visible)
            }
        }
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.gamePurple.opacity(0.1)))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gamePurple.opacity(0.5), lineWidth: 3)
        )
    }
}

struct BinaryInputView: View {
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: Binding(
            get: { self.text },
            set: { newValue in
                // Check if this is a deletion operation
                if newValue.count < self.text.count {
                    // Custom handling for deletion to remove both digit and space
                    if let lastCharRemoved = findRemovedCharacter(from: self.text, to: newValue) {
                        var updatedText = newValue
                        
                        // If we deleted a digit and there's a space before it, remove that space too
                        if lastCharRemoved == "0" || lastCharRemoved == "1", updatedText.hasSuffix(" ") {
                            updatedText = String(updatedText.dropLast())
                        }
                        
                        // If we deleted a space and there was a digit before it, remove that digit too
                        if lastCharRemoved == " ", !updatedText.isEmpty, updatedText.last == "0" || updatedText.last == "1" {
                            updatedText = String(updatedText.dropLast())
                        }
                        
                        self.text = updatedText
                        return
                    }
                    
                    // If we couldn't determine exactly what was deleted, just use the new value
                    self.text = newValue
                    return
                }
                
                // Format the input to break lines after every 8 digits
                let cleanedInput = newValue.filter { $0 == "0" || $0 == "1" || $0 == "\n" || $0 == " " }
                
                // Process the cleaned input to ensure correct line breaks
                var formattedText = ""
                var digitCount = 0 // Count of actual digits (not spaces)
                var justAddedNewline = false // Track if we just added a newline
                
                for char in cleanedInput {
                    if char == "\n" {
                        // Only add the newline if we haven't just added one
                        if !justAddedNewline {
                            formattedText.append("\n")
                            justAddedNewline = true
                        }
                        digitCount = 0
                    } else if char == " " {
                        // Skip spaces - we'll add them as needed
                    } else { // char is 0 or 1
                        formattedText.append(char)
                        digitCount += 1
                        justAddedNewline = false
                        
                        // Add space after digit (except for the last one in a row)
                        if digitCount < 8 {
                            formattedText.append(" ")
                        }
                        
                        // Add newline after 8 digits
                        if digitCount == 8 {
                            formattedText.append("\n")
                            justAddedNewline = true
                            digitCount = 0
                        }
                    }
                }
                
                self.text = formattedText
            }
        ))
        .font(.system(.title2, design: .monospaced))
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gamePurple.opacity(0.6), lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gamePurple.opacity(0.1))
        )
        .frame(height: 300)
    }
    
    // Helper function to find which character was removed during a deletion
    private func findRemovedCharacter(from oldText: String, to newText: String) -> Character? {
        if oldText.count - newText.count != 1 {
            return nil // Multiple characters changed, can't determine single removed character
        }
        
        // Find the index where the texts differ
        let oldArray = Array(oldText)
        let newArray = Array(newText)
        
        for i in 0 ..< newArray.count {
            if i >= oldArray.count || oldArray[i] != newArray[i] {
                return oldArray[i]
            }
        }
        
        // If we get here, the removed character is the last one
        return oldArray.last
    }
}

// MARK: - Previews

#Preview("Intro Phase") {
    let viewModel = PixelGameViewModel()
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Questions Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .questions
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Exploration Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .exploration
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Novice Challenge Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .noviceChallenge
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Apprentice Challenge Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .apprenticeChallenge
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Adept Challenge Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .adeptChallenge
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Expert Challenge Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .expertChallenge
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}

#Preview("Review Phase") {
    let viewModel = PixelGameViewModel()
    viewModel.currentPhase = .review
    return PixelGameView(viewModel: viewModel)
        .environment(\.colorScheme, .light)
}
