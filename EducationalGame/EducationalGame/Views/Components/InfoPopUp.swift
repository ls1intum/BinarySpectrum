import SwiftUI

struct InfoPopup: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.gameBlack.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(title)
                    .font(GameTheme.headingFont)
                    .foregroundColor(.gamePurple)

                Text(message)
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                Button(action: onButtonTap) {
                    Text(buttonTitle)
                        .font(GameTheme.buttonFont)
                        .foregroundColor(.gameWhite)
                        .padding()
                        .frame(width: 200)
                        .background(Color.gameOrange)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TwoButtonInfoPopup: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String
    let onPrimaryButtonTap: () -> Void
    let onSecondaryButtonTap: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.gameBlack.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(title)
                    .font(GameTheme.headingFont)
                    .foregroundColor(.gamePurple)

                Text(message)
                    .font(GameTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gameDarkBlue)
                    .padding(.horizontal)

                HStack(spacing: 20) {
                    // Secondary button
                    Button(action: onSecondaryButtonTap) {
                        Text(secondaryButtonTitle)
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameDarkBlue)
                            .padding()
                            .frame(width: 180)
                            .background(Color.gameGray)
                            .cornerRadius(12)
                    }

                    // Primary button
                    Button(action: onPrimaryButtonTap) {
                        Text(primaryButtonTitle)
                            .font(GameTheme.buttonFont)
                            .foregroundColor(.gameWhite)
                            .padding()
                            .frame(width: 180)
                            .background(Color.gameOrange)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gameWhite.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gamePurple, lineWidth: 5)
                    )
            )
            .shadow(radius: 10)
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    InfoPopup(title: "Information", message: "This is an important message for the user that requires attention.", buttonTitle: "OK", onButtonTap: {})
}

#Preview("Two Buttons") {
    TwoButtonInfoPopup(
        title: "Confirm Action",
        message: "Are you sure you want to proceed with this action?",
        primaryButtonTitle: "Confirm",
        secondaryButtonTitle: "Cancel",
        onPrimaryButtonTap: {},
        onSecondaryButtonTap: {}
    )
}
