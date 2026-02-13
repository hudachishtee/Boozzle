import SwiftUI

struct PuzzleResultView: View {
    var didWin: Bool
    var resetAction: () -> Void
    var successAction: () -> Void = {} // ✅ Added this action
    
    private let purple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let orange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let buttonPurple = Color(red: 0x67/255, green: 0x2F/255, blue: 0x50/255)
    private let lightpurp = Color(red: 0x58/255, green: 0x2A/255, blue: 0x54/255)

    // Layout constants
    private let topPadding: CGFloat = 72
    private let ghostHeightWin: CGFloat = 150
    private let ghostHeightLose: CGFloat = 150
    private let cardCornerRadius: CGFloat = 24
    private let cardHeight: CGFloat = 260
    private let cardHorizontalPadding: CGFloat = 28
    private let titleFontSize: CGFloat = 26
    private let chairMaxWidth: CGFloat = 290
    private let chairMaxHeight: CGFloat = 180
    private let buttonHorizontalPadding: CGFloat = 40
    private let buttonVerticalPadding: CGFloat = 18
    private let buttonFontSize: CGFloat = 26
    private let spacingAfterGhost: CGFloat = 32
    private let spacingAfterCard: CGFloat = 36

    var body: some View {
        ZStack {
            LinearGradient(colors: [purple, orange], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            content.padding(.horizontal, 0)
        }
    }

    @ViewBuilder
    private var content: some View {
        if didWin {
            winningView
                .contentShape(Rectangle())
                .onTapGesture {
                    successAction() // ✅ Triggers the close action
                }
        } else {
            losingView
        }
    }

    private var winningView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: topPadding)

            Text("Item restored!")
                .font(.custom("Arial-Black", size: titleFontSize))
                .kerning(0.5)
                .foregroundStyle(.white.opacity(0.98))
                .shadow(color: .black.opacity(0.45), radius: 1.2, x: 0, y: 1)

            Image("ghostie")
                .resizable().scaledToFit().frame(height: ghostHeightWin)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                .padding(.top, 6)

            Spacer().frame(height: spacingAfterGhost)

            ZStack {
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .fill(lightpurp)
                    .overlay(RoundedRectangle(cornerRadius: cardCornerRadius).stroke(lightpurp, lineWidth: 4))

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 255/255, green: 218/255, blue: 119/255).opacity(0.55),
                        Color.orange.opacity(0.12),
                        Color.clear
                    ]),
                    center: .center, startRadius: 10, endRadius: 260
                )
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                .allowsHitTesting(false)

                VStack(spacing: 12) {
                    Image("chair")
                        .resizable().scaledToFit().frame(maxWidth: chairMaxWidth, maxHeight: chairMaxHeight)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 18).padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity).frame(height: cardHeight)
            .padding(.horizontal, cardHorizontalPadding)

            Spacer().frame(height: spacingAfterCard)

            Text("tap to continue...")
                .font(.custom("Arial-Black", size: 18))
                .foregroundStyle(.white.opacity(0.85))
                .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)

            Spacer(minLength: 40)
        }
    }

    private var losingView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Game Over")
                .font(.custom("Arial-Black", size: 30))
                .foregroundStyle(.white.opacity(0.98))
                .shadow(color: .black.opacity(0.45), radius: 1.2, x: 0, y: 1)

            Image("ghostie")
                .resizable().scaledToFit().frame(height: ghostHeightLose)
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)

            VStack(spacing: 14) {
                Button { resetAction() } label: {
                    Text("Play again")
                        .font(.custom("Arial-Black", size: buttonFontSize))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, buttonVerticalPadding)
                        .background(Capsule().fill(buttonPurple.opacity(0.7)))
                        .overlay(Capsule().stroke(buttonPurple.opacity(0.95), lineWidth: 2))
                }
            }
            .padding(.horizontal, buttonHorizontalPadding)

            Spacer()
        }
    }
}
