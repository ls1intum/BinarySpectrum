import SwiftUI

func navigateTo<Destination: View>(_ destination: Destination) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first
    {
        window.rootViewController = UIHostingController(rootView: destination)
        window.makeKeyAndVisible()
    }
}
