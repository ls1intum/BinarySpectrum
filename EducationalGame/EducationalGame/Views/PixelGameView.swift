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
                InstructionBar(text: instruction)
                    .padding(.top, 20)
                
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
                            action: onCheck
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            if viewModel.showHint {
                InfoPopup(
                    title: viewModel.isCorrect ? "Correct!" : "Try Again",
                    message: viewModel.hintMessage,
                    buttonTitle: "OK",
                    onButtonTap: {
                        viewModel.hideHint()
                    }
                )
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
            instruction: "Create your own pixel art by tapping the grid squares. When you're done, tap the check button to continue.",
            showCheckButton: true,
            onCheck: { viewModel.nextPhase() }
        ) {
            VStack(spacing: 20) {
                Text("Pixel Art Canvas")
                    .font(GameTheme.titleFont)
                    .foregroundColor(.gameBlack)
                
                PixelGridView(
                    viewModel: viewModel,
                    showBinary: true
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(20)
                
                HStack(spacing: 20) {
                    Button(action: { viewModel.gridState.reset() }) {
                        Label("Clear Grid", systemImage: "trash")
                            .padding()
                            .background(Color.gameRed.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
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
            VStack(spacing: 30) {
                HStack(alignment: .top, spacing: 40) {
                    VStack(spacing: 15) {
                        Text("Binary Code")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        BinaryCodeView(code: viewModel.formattedCode)
                            .frame(width: 220, height: 280)
                    }
                    
                    VStack(spacing: 15) {
                        Text("Your Canvas")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        PixelGridView(
                            viewModel: viewModel,
                            showBinary: false
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                
                VStack(spacing: 15) {
                    Text("Progress")
                        .font(GameTheme.captionFont)
                        .foregroundColor(.gray)
                    
                    ProgressView(value: viewModel.gridState.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .gameBlue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(width: 300)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                }
                
                HStack(spacing: 20) {
                    Button(action: { viewModel.gridState.reset() }) {
                        Label("Clear Grid", systemImage: "trash")
                            .padding()
                            .background(Color.gameRed.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Text("Art: \(viewModel.decodingState.currentArt.name)")
                        .font(GameTheme.captionFont)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.gameGray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct PixelEncodingView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Write the binary code for this image. Remember: 1 for black pixels, 0 for white pixels, 8 bits per row.",
            onCheck: { viewModel.checkBinaryEncoding() }
        ) {
            VStack(spacing: 30) {
                HStack(alignment: .top, spacing: 40) {
                    VStack(spacing: 15) {
                        Text("Pixel Image")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        PixelGridView(
                            viewModel: viewModel,
                            showBinary: false,
                            fixedCells: viewModel.encodingState.encodingChallengeGrid
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("Art: \(GameConstants.pixelArt8x8[viewModel.encodingState.currentArtIndex].name)")
                            .font(GameTheme.captionFont)
                            .foregroundColor(.gray)
                            .padding(5)
                            .background(Color.gameGray.opacity(0.1))
                            .cornerRadius(5)
                    }
                    
                    VStack(spacing: 15) {
                        Text("Your Binary Code")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        BinaryInputView(text: $viewModel.encodingState.playerBinaryCode)
                            .frame(width: 250, height: 300)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: { viewModel.encodingState.playerBinaryCode = "" }) {
                        Label("Clear Code", systemImage: "trash")
                            .padding()
                            .background(Color.gameRed.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Provide a hint by showing one row
                        let rows = viewModel.correctBinaryEncoding.split(separator: "\n")
                        if let firstRow = rows.first {
                            viewModel.encodingState.playerBinaryCode = String(firstRow)
                            if rows.count > 1 {
                                viewModel.encodingState.playerBinaryCode += "\n"
                            }
                        }
                    }) {
                        Label("Show Hint", systemImage: "lightbulb")
                            .padding()
                            .background(Color.gameYellow.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}

struct PixelAdeptChallengeView: View {
    @Bindable var viewModel: PixelGameViewModel
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Create or load pixel art on this 16×16 grid. Your art will be encoded as a 64-character hex string.",
            onCheck: { viewModel.nextPhase() }
        ) {
            VStack(spacing: 20) {
                Text("16×16 Pixel Canvas")
                    .font(GameTheme.titleFont)
                    .foregroundColor(.gameBlack)
                
                PixelGridView(
                    viewModel: viewModel,
                    showBinary: false
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(15)
                
                HStack(alignment: .top, spacing: 20) {
                    VStack(spacing: 10) {
                        Button(action: { viewModel.gridState.reset() }) {
                            Label("Clear Grid", systemImage: "trash")
                                .padding()
                                .background(Color.gameRed.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.generateHexOutput()
                        }) {
                            Label("Generate Hex", systemImage: "number")
                                .padding()
                                .background(Color.gameBlue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text("Example Art")
                            .font(GameTheme.captionFont)
                            .foregroundColor(.gameBlack)
                        
                        Menu {
                            ForEach(GameConstants.pixelArt16x16) { art in
                                Button(art.name) {
                                    viewModel.selectArt(art: art)
                                }
                            }
                            
                            Button("None") {
                                viewModel.clearSelectedArt()
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedArt)
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.gameGreen.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                
                // Hex output display
                VStack(spacing: 5) {
                    Text("Hex String Representation")
                        .font(GameTheme.captionFont)
                        .foregroundColor(.gameBlack)
                    
                    ScrollView {
                        Text(viewModel.hexOutput.isEmpty ? "Create some art and tap 'Generate Hex'" : viewModel.hexOutput)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gamePurple.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .frame(height: 80)
                    
                    if !viewModel.hexOutput.isEmpty {
                        Button(action: {
                            UIPasteboard.general.string = viewModel.hexOutput
                        }) {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gameYellow.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            // Initialize 16x16 grid on view appear
            viewModel.setupAdeptChallenge()
        }
    }
}

struct PixelFinalChallengeView: View {
    @Bindable var viewModel: PixelGameViewModel
    @State private var gridSize: Int = 8
    
    var body: some View {
        PixelChallengeBaseView(
            viewModel: viewModel,
            instruction: "Create your own pixel art masterpiece! Toggle between 8×8 and 16×16 grid sizes, and try to optimize your design for compression.",
            onCheck: { viewModel.nextPhase() }
        ) {
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
                    
                    TextField("Name your art", text: $viewModel.artName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                }
                
                HStack(alignment: .top, spacing: 20) {
                    VStack(spacing: 15) {
                        Text("Pixel Canvas")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        PixelGridView(
                            viewModel: viewModel,
                            showBinary: false
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        HStack(spacing: 15) {
                            Button(action: { viewModel.gridState.reset() }) {
                                Label("Clear", systemImage: "trash")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.gameRed.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.saveArt()
                            }) {
                                Label("Save", systemImage: "square.and.arrow.down")
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.gameBlue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(viewModel.artName.isEmpty)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text("Compression Challenge")
                            .font(GameTheme.subtitleFont)
                            .foregroundColor(.gray)
                        
                        // Educational content about compression
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Run-Length Encoding (RLE)")
                                .font(GameTheme.captionFont)
                                .foregroundColor(.gameBlack)
                            
                            Text("Computing uses RLE to compress data by storing runs of identical values as a count and value instead of repeating the same value multiple times.")
                                .font(GameTheme.bodyFont)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color.gameYellow.opacity(0.1))
                                .cornerRadius(8)
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
                            Text(viewModel.compressionText)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gamePurple.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .frame(height: 100)
                        
                        // Compression results
                        if viewModel.compressionRatio > 0 {
                            VStack(spacing: 5) {
                                Text("Compression Results")
                                    .font(GameTheme.captionFont)
                                    .foregroundColor(.gameBlack)
                                
                                HStack {
                                    Text("Compression Ratio: \(String(format: "%.1f", viewModel.compressionRatio))×")
                                        .font(GameTheme.bodyFont)
                                        .foregroundColor(.gameBlue)
                                    
                                    Spacer()
                                    
                                    Text("Score: \(viewModel.compressionScore)")
                                        .font(GameTheme.titleFont)
                                        .foregroundColor(viewModel.compressionScore > 50 ? .gameGreen : .gameRed)
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                            .background(Color.gameWhite)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .frame(width: 300)
                }
                
                if viewModel.showSaveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.gameGreen)
                        Text("Saved \"\(viewModel.artName)\" successfully!")
                            .foregroundColor(.gameGreen)
                        if gridSize == 16 {
                            Text("Hex String: \(viewModel.savedArtString)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gameGreen.opacity(0.1))
                    .cornerRadius(10)
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.gridState.cellSize)), count: viewModel.gridState.gridSize), spacing: 2) {
                ForEach(0 ..< (viewModel.gridState.gridSize * viewModel.gridState.gridSize), id: \.self) { index in
                    PixelCell(
                        isBlack: fixedCells?.contains(index) ?? viewModel.gridState.blackCells.contains(index),
                        showBinary: showBinary,
                        size: viewModel.gridState.cellSize,
                        onTap: fixedCells == nil ? { viewModel.toggleCell(index) } : nil
                    )
                }
            }
            .padding(8)
        }
        .frame(width: CGFloat(viewModel.gridState.gridSize) * viewModel.gridState.cellSize + CGFloat(viewModel.gridState.gridSize - 1) * 2 + 16,
               height: CGFloat(viewModel.gridState.gridSize) * viewModel.gridState.cellSize + CGFloat(viewModel.gridState.gridSize - 1) * 2 + 16)
    }
}

struct PixelCell: View {
    let isBlack: Bool
    let showBinary: Bool
    let size: CGFloat
    let onTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isBlack ? Color.gameBlack : Color.gameWhite)
                .frame(width: size, height: size)
                .border(Color.gray.opacity(0.3), width: 1)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            if showBinary {
                Text(isBlack ? "1" : "0")
                    .font(.system(size: size * 0.4, weight: .medium))
                    .foregroundColor(isBlack ? .gameWhite : .gray)
            }
        }
        .onTapGesture {
            onTap?()
        }
    }
}

struct BinaryCodeView: View {
    let code: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        }
        .background(Color.gameBlue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gameBlue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct BinaryInputView: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color.gamePurple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gamePurple.opacity(0.3), lineWidth: 1)
                )
        }
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
