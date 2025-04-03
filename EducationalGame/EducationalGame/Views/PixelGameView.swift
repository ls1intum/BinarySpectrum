import SwiftUI

struct PixelGameView: View {
    @State private var viewModel = PixelGameViewModel()
    
    var body: some View {
        VStack {
            TopBarView(title: GameConstants.miniGames[1].name, color: GameConstants.miniGames[1].color)
            Spacer()
            InstructionBar(text: "Decode the image. Remember: if a pixel is 1, turn it black. If it’s 0, leave it white.")
            Spacer()
            HStack {
                Spacer()
                GridView(viewModel: viewModel)
                Spacer()
                VStack {
                    // Format the code for display
                    Text(viewModel.formattedCode)
                        .font(.headline)
                        .padding()
                        .background(Color.gamePurple.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 8)  // Adjust the space between the grid and code
                    
                    ProgressBar(progress: viewModel.progress)
                        .frame(height: 20)
                        .padding()
                }
                .frame(width: 200)
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
}

struct GridView: View {
    @ObservedObject var viewModel: PixelGameViewModel
    
    let gridSize = 8
    let cellSize: CGFloat = 30
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2) // Gray background behind the grid
                .cornerRadius(10)
                .padding(2) // Reduce padding to avoid extra height
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize)), count: gridSize), spacing: 2) {
                ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                    Rectangle()
                        .fill(viewModel.blackCells.contains(index) ? Color.black : Color.white)
                        .frame(width: cellSize, height: cellSize)
                        .border(Color.gray, width: 1)
                        .onTapGesture {
                            viewModel.toggleCell(index)
                        }
                }
            }
            .padding(0) // No extra padding for the grid itself
        }
        .frame(width: CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * 2, height: CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * 2) // Adjust the frame for both width and height
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        ProgressView(value: progress, total: 1.0)
            .progressViewStyle(LinearProgressViewStyle())
            .accentColor(.blue)
            .padding()
    }
}

#Preview {
    PixelGameView()
}
