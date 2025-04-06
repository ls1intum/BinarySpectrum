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
            case .tutorial:
                DialogueView(
                    characterIcon: "slider.horizontal.below.rectangle",
                    dialogues: viewModel.hexLearningDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .practice:
                ColorHexChallenge(viewModel: viewModel)
            case .challenges:
                DialogueView(
                    characterIcon: "slider.horizontal.below.rectangle",
                    dialogues: viewModel.opacityLearningDialogue,
                    currentPhase: $viewModel.currentPhase
                )
            case .advancedChallenges:
                ColorAlphaChallenge(viewModel: viewModel)
            case .finalChallenge:
                ColorFinalChallenge(viewModel: viewModel)
            case .review:
                ColorReview(viewModel: viewModel)
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
            
            Button(action: {
                viewModel.currentPhase = .tutorial
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
}

struct ColorHexChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: "Match the target color using the RGB sliders!")
            
            HStack(spacing: 60) {
                // Target Color
                VStack {
                    Text("Target Color")
                        .font(GameTheme.subtitleFont)
                    Circle()
                        .fill(viewModel.targetColor)
                        .frame(width: 150, height: 150)
                        .shadow(radius: 5)
                    Text(viewModel.targetColorHex)
                        .font(.headline)
                        .padding(8)
                        .background(Color.gameGray)
                        .cornerRadius(8)
                }
                
                // Current Color
                VStack {
                    Text("Your Color")
                        .font(GameTheme.subtitleFont)
                    Circle()
                        .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue))
                        .frame(width: 150, height: 150)
                        .shadow(radius: 5)
                    Text(viewModel.currentColorHex)
                        .font(.headline)
                        .padding(8)
                        .background(Color.gameGray)
                        .cornerRadius(8)
                }
            }
            
            VStack(spacing: 20) {
                ColorSlider(value: $viewModel.red, color: .red)
                ColorSlider(value: $viewModel.green, color: .green)
                ColorSlider(value: $viewModel.blue, color: .blue)
            }
            .padding(.horizontal, 50)
            
            ColorGameControls(viewModel: viewModel)
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: false)
        }
    }
}

struct ColorAlphaChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: "Match the target color including its opacity!")
            
            HStack(spacing: 60) {
                // Target Color
                VStack {
                    Text("Target Color")
                        .font(GameTheme.subtitleFont)
                    ZStack {
                        CheckerboardBackground()
                        Circle()
                            .fill(viewModel.targetColor.opacity(viewModel.targetAlpha))
                            .frame(width: 150, height: 150)
                    }
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    Text("\(viewModel.targetColorHex) (Alpha: \(Int(viewModel.targetAlpha * 100))%)")
                        .font(.headline)
                        .padding(8)
                        .background(Color.gameGray)
                        .cornerRadius(8)
                }
                
                // Current Color
                VStack {
                    Text("Your Color")
                        .font(GameTheme.subtitleFont)
                    ZStack {
                        CheckerboardBackground()
                        Circle()
                            .fill(Color(red: viewModel.red, green: viewModel.green, blue: viewModel.blue)
                                .opacity(viewModel.alpha))
                            .frame(width: 150, height: 150)
                    }
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    Text("\(viewModel.currentColorHex) (Alpha: \(Int(viewModel.alpha * 100))%)")
                        .font(.headline)
                        .padding(8)
                        .background(Color.gameGray)
                        .cornerRadius(8)
                }
            }
            
            VStack(spacing: 20) {
                ColorSlider(value: $viewModel.red, color: .red)
                ColorSlider(value: $viewModel.green, color: .green)
                ColorSlider(value: $viewModel.blue, color: .blue)
                ColorSlider(value: $viewModel.alpha, color: .gray)
            }
            .padding(.horizontal, 50)
            
            ColorGameControls(viewModel: viewModel)
        }
        .onAppear {
            viewModel.generateNewTargetColor(includeAlpha: true)
        }
    }
}

struct ColorFinalChallenge: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: "Final Challenge: Match the target color with limited attempts!")
            
            // Same as ColorAlphaChallenge but with attempt counter
            ColorAlphaChallenge(viewModel: viewModel)
            
            Text("Attempts remaining: \(viewModel.attemptsRemaining)")
                .font(.headline)
                .foregroundColor(viewModel.attemptsRemaining < 3 ? .red : .primary)
        }
    }
}

struct ColorReview: View {
    @ObservedObject var viewModel: ColorGameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            InstructionBar(text: "Let's review what you've learned!")
            
            VStack(alignment: .leading, spacing: 20) {
                Text("RGB Colors")
                    .font(.title2)
                    .bold()
                Text("• Red, Green, and Blue are the primary colors of light")
                Text("• Mixing them creates all other colors")
                Text("• Each value ranges from 0 to 255")
                
                Text("Opacity")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                Text("• Controls how transparent a color is")
                Text("• 1.0 = completely solid")
                Text("• 0.0 = completely transparent")
                
                Text("Hex Codes")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                Text("• A way to represent RGB values in hexadecimal")
                Text("• Each pair of characters represents one color")
                Text("• Example: #FF0000 = pure red")
            }
            .padding()
            .background(Color.gameGray.opacity(0.3))
            .cornerRadius(15)
            
            Button(action: {
                viewModel.currentPhase = .reward
            }) {
                Text("Continue to Reward")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
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
                        if viewModel.currentPhase == .practice {
                            viewModel.currentPhase = .challenges // Move to opacity explanation
                        } else {
                            viewModel.currentPhase = .reward
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
