import SwiftUI

struct PixelGameView: View {
    
    var body: some View {
        TopBarView(title:"Pixel Game", color: .gameGreen)
        
    }
}
import SwiftUI

struct GridView: View {
    let gridSize = 16
    let cellSize: CGFloat = 30 // Adjust for different screen sizes
    
    @State private var blackCells: Set<Int> = [] // Stores the black squares
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize)), count: gridSize), spacing: 2) {
            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                Rectangle()
                    .fill(blackCells.contains(index) ? Color.black : Color.white)
                    .frame(width: cellSize, height: cellSize)
                    .border(Color.gray, width: 1)
                    .onTapGesture {
                        toggleCell(index)
                    }
            }
        }
        .padding()
    }
    
    private func toggleCell(_ index: Int) {
        if blackCells.contains(index) {
            blackCells.remove(index)
        } else {
            blackCells.insert(index)
        }
    }
}

#Preview {
    GridView()
}

#Preview {
    PixelGameView()
}
