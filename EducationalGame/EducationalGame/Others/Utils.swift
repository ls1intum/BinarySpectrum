import SwiftUI

func navigateTo<Destination: View>(_ destination: Destination) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first
    {
        window.rootViewController = UIHostingController(rootView: destination)
        window.makeKeyAndVisible()
    }
}

extension String {
    func paddingLeft(with character: Character, toLength: Int) -> String {
        return String(repeating: String(character), count: max(0, toLength - count)) + self
    }
}