import Foundation
import SwiftUICore

@Observable class BinaryGameViewModel: ObservableObject {
    
    // manager of the flow of the mini game
    
    
    // phases of the mini game and their data
    var currentPhase = GamePhase.allCases[0];
    
    let introDialogue = ["Welcome to Binary Game!", "You are a binary code detective.", "Your mission is to decode the binary code."];
    
    // decide if the player is beginner or advanced and change gameplay accordingly
    
    
    
    
}
