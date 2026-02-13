import SwiftUI

struct AfterPuzzleScreen: View {
    // ✅ ADDED: This lets the Game pass the real number to this screen
    var score: Int
    
    // MARK: - Colors
    private let purple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let orange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let lightpurp = Color(red: 0x58/255, green: 0x2A/255, blue: 0x54/255)
    
    // MARK: - Layout
    private let topPadding: CGFloat = 72
    private let ghostHeightWin: CGFloat = 150
    private let cardCornerRadius: CGFloat = 24
    private let cardHeight: CGFloat = 260
    private let cardHorizontalPadding: CGFloat = 28
    private let titleFontSize: CGFloat = 26
    private let coinMaxWidth: CGFloat = 110
    private let coinMaxHeight: CGFloat = 110
    private let spacingAfterGhost: CGFloat = 32
    private let spacingAfterCard: CGFloat = 36
    
    var body: some View {
        ZStack {
            // Gradient fills the entire screen
            LinearGradient(
                colors: [purple, orange],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: topPadding)
                
                Text("Good Job!")
                    .font(.custom("Arial-Black", size: titleFontSize))
                    .kerning(0.5)
                    .foregroundStyle(.white.opacity(0.98))
                    .shadow(color: .black.opacity(0.45), radius: 1.2, x: 0, y: 1)
                
                Image("ghostie")
                    .resizable()
                    .scaledToFit()
                    .frame(height: ghostHeightWin)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                    .padding(.top, 6)
                
                Spacer().frame(height: spacingAfterGhost)
                
                ZStack {
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .fill(lightpurp)
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                                .stroke(lightpurp, lineWidth: 4)
                        )
                    
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 255/255, green: 218/255, blue: 119/255).opacity(0.55),
                            orange.opacity(0.12),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 260
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                    .allowsHitTesting(false)
                    
                    VStack(spacing: 8) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: coinMaxWidth, maxHeight: coinMaxHeight)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                            .padding(.top, -10)
                        
                        // ✅ UPDATED: Now shows the REAL score instead of "1500"
                        Text("\(score)")
                            .font(.custom("Arial-Black", size: 24))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
                .padding(.horizontal, cardHorizontalPadding)
                
                Spacer().frame(height: spacingAfterCard)
                
                Text("tap to continue...")
                    .font(.custom("Arial-Black", size: 18))
                    .foregroundStyle(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)
                
                Spacer(minLength: 40)
            }
            // This makes VStack stretch to fill gradient
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// ✅ PREVIEW FIX (This stops the "Missing argument" error)
struct AfterPuzzleScreen_Previews: PreviewProvider {
    static var previews: some View {
        AfterPuzzleScreen(score: 1500)
            .previewDevice("iPhone 14")
    }
}
