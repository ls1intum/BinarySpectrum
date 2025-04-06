import SwiftUI

struct ColorGameView: View {
    @State private var viewModel = ColorGameViewModel()
    
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[2].name, color: GameConstants.miniGames[2].color)
            
            switch viewModel.currentPhase {
            case .intro:
                DialogueView(
                    characterIcon: "paintpalette.fill",
                    dialogues: viewModel.introDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .questions:
                QuestionsView(
                    questions: viewModel.introQuestions,
                    currentPhase: $viewModel.currentPhase
                )
            case .exploration:
                ColorExploration(viewModel: viewModel)
            case .challenges:
                ColorChallenge(viewModel: viewModel)
            case .reward:
                RewardView(
                    message: "Congratulations! You've mastered RGB colors, hex codes, and opacity!",
                    onContinue: { viewModel.resetGame() }
                )
            }
        }
    }
}

struct ColorExploration: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                InstructionBar(text: "Experiment with the RGB sliders to create different colors!")
                
                Circle()
                    .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue))
                    .frame(width: 200, height: 200)
                    .shadow(radius: 5)
                
                Text(viewModel.currentColorHex)
                    .font(.title)
                    .padding(8)
                    .background(Color.gameGray)
                    .cornerRadius(8)
                
                VStack(spacing: 20) {
                    ColorSlider(value: $viewModel.red, color: .red)
                    ColorSlider(value: $viewModel.green, color: .green)
                    ColorSlider(value: $viewModel.blue, color: .blue)
                }
                .padding(.horizontal, 50)
            }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        viewModel.currentPhase = .challenges
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 40)
                    .padding(.bottom, 30)
                    Spacer()
                }
            }
        }
    }
}

struct ColorChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    @State private var showingHexCodes = false
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: viewModel.showingOpacity ? 
                "Match both the color and opacity of the target" :
                "Match the target color by adjusting the RGB sliders")
            
            HStack(spacing: 60) {
                // Target Color
                VStack {
                    Text("Target Color")
                        .font(GameTheme.subtitleFont)
                    ZStack {
                        if viewModel.showingOpacity {
                            CheckerboardBackground()
                        }
                        Circle()
                            .fill(viewModel.targetColor.opacity(viewModel.showingOpacity ? viewModel.targetAlpha : 1))
                            .frame(width: 150, height: 150)
                    }
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    if showingHexCodes {
                        Text(viewModel.targetColorHex)
                            .font(.headline)
                            .padding(8)
                            .background(Color.gameGray)
                            .cornerRadius(8)
                    }
                }
                
                // Current Color
                VStack {
                    Text("Your Color")
                        .font(GameTheme.subtitleFont)
                    ZStack {
                        if viewModel.showingOpacity {
                            CheckerboardBackground()
                        }
                        Circle()
                            .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue)
                                .opacity(viewModel.showingOpacity ? viewModel.alpha : 1))
                            .frame(width: 150, height: 150)
                    }
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    if showingHexCodes {
                        Text(viewModel.currentColorHex)
                            .font(.headline)
                            .padding(8)
                            .background(Color.gameGray)
                            .cornerRadius(8)
                    }
                }
            }
            
            VStack(spacing: 20) {
                ColorSlider(value: $viewModel.red, color: .red)
                ColorSlider(value: $viewModel.green, color: .green)
                ColorSlider(value: $viewModel.blue, color: .blue)
                if viewModel.showingOpacity {
                    ColorSlider(value: $viewModel.alpha, color: .gray)
                }
            }
            .padding(.horizontal, 50)
            
            ColorGameControls(viewModel: viewModel)
            
            Button(action: {
                showingHexCodes.toggle()
            }) {
                Text(showingHexCodes ? "Hide Hex Codes" : "Show Hex Codes")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: viewModel.showingOpacity)
        }
    }
}

struct ColorGameControls: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack {
            if viewModel.showHint {
                Text(viewModel.hintMessage)
                    .font(.headline)
                    .foregroundColor(viewModel.isCorrect ? .green : .orange)
                    .padding()
                    .multilineTextAlignment(.center)
                
                if viewModel.isCorrect {
                    Button(action: {
                        if viewModel.showingOpacity {
                            viewModel.currentPhase = .reward
                        } else {
                            viewModel.hideHint()
                            viewModel.generateNewTargetColor(includeAlpha: true)
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .padding()
                            .frame(width: 160)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        viewModel.hideHint()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .padding()
                            .frame(width: 160)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Button(action: {
                    viewModel.checkColorMatch()
                }) {
                    Text("Check Color")
                        .font(.headline)
                        .padding()
                        .frame(width: 160)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

struct CheckerboardBackground: View {
    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 10
            let rows = Int(size.height / tileSize)
            let columns = Int(size.width / tileSize)
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let rect = CGRect(x: CGFloat(col) * tileSize,
                                    y: CGFloat(row) * tileSize,
                                    width: tileSize,
                                    height: tileSize)
                    
                    context.fill(Path(rect), with: .color((row + col).isMultiple(of: 2) ? .white : .gray.opacity(0.3)))
                }
            }
        }
        .frame(width: 150, height: 150)
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    var color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
            
            Slider(value: $value)
                .accentColor(color)
                .frame(width: 400)
            
            Text(String(format: "%.0f", value * 255))
                .frame(width: 40)
                .font(.headline)
        }
        .padding()
        .background(Color.gameGray.opacity(0.3))
        .cornerRadius(15)
    }
}

#Preview {
    ColorGameView()
}
