import SwiftUI

struct PuzzleResultView: View {
    var didWin: Bool
    var restoredImageName: String
    var resetAction: () -> Void
    var successAction: () -> Void = {}
    
    private let purple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let orange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let buttonPurple = Color(red: 0x67/255, green: 0x2F/255, blue: 0x50/255)
    private let lightpurp = Color(red: 0x58/255, green: 0x2A/255, blue: 0x54/255)

    var body: some View {
        ZStack {
            LinearGradient(colors: [purple, orange], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if didWin {
                winningLayout
            } else {
                losingLayout
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var winningLayout: some View {
        VStack(spacing: 25) {
            Text("Item restored!")
                .font(.custom("Arial-Black", size: 28))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 1, y: 1)

            Image("ghostie")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .shadow(color: .black.opacity(0.25), radius: 6, y: 4)

            VStack {
                Image(restoredImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 6)
            }
            .padding(22)
            .frame(width: 300)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(lightpurp.opacity(0.7))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(lightpurp.opacity(0.95), lineWidth: 4))
                    
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 255/255, green: 218/255, blue: 119/255).opacity(0.55),
                            Color.orange.opacity(0.12),
                            Color.clear
                        ]),
                        center: .center, startRadius: 10, endRadius: 200
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            )

            Text("tap to continue...")
                .font(.custom("Arial-Black", size: 18))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 10)
        }
        // 🚨 EMERGENCY OVERRIDE: NAILS IT TO THE EXACT CENTER OF THE SCREEN
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        .contentShape(Rectangle())
        .onTapGesture { successAction() }
    }

    private var losingLayout: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.custom("Arial-Black", size: 30))
                .foregroundStyle(.white)
            
            Image("ghostie")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
            
            Button { resetAction() } label: {
                Text("Play again")
                    .font(.custom("Arial-Black", size: 26))
                    .foregroundStyle(.white)
                    .frame(width: 280)
                    .padding(.vertical, 18)
                    .background(Capsule().fill(buttonPurple.opacity(0.7)))
            }
        }
        // 🚨 EMERGENCY OVERRIDE
        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    }
}
