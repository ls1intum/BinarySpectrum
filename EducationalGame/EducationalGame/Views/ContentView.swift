import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            TopBarView(title: "Educational Game", leftIcon: "gear")
            
            VStack(spacing: 40) {
                Spacer()
                HStack(spacing: 20) {
                    NavigationLink(destination: BinaryGameView()) {
                        GameButtonView(color: .gameRed, icon: "number", title: "Binary Game")
                    }
                    
                    NavigationLink(destination: PixelGameView()) {
                        GameButtonView(color: .gameGreen, icon: "photo.on.rectangle", title: "Pixel Game")
                    }
                    
                    NavigationLink(destination: ColorGameView()) {
                        GameButtonView(color: .gameBlue, icon: "paintpalette", title: "Color Game")
                    }
                }
                
                // Bottom Buttons (Achievements & Another Feature)
                HStack(spacing: 20) {
                    Button(action: {
                        print("Achievements tapped!")
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Achievements")
                        }
                        .padding()
                        .frame(width: 480, height: 80)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                    Button(action: {
                        print("Another Feature tapped!")
                    }) {
                        Text("More Features")
                            .padding()
                            .frame(width: 480, height: 80)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("BR") {
    ContentView()
        .environment(\.locale, Locale(identifier: "pt_BR"))
}
