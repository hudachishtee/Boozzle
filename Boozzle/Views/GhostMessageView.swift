import SwiftUI

struct GhostMessages: View {

    // MARK: - Inputs
    let title: String
    let onTap: () -> Void

    var body: some View {
        VStack {
            Spacer()

            // Bubble + Ghost container
            ZStack(alignment: .bottomLeading) {

                // Bubble
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)

                    Text(title)
                        .font(.system(size: 23, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 30)
                }
                .frame(height: 200)
                .padding(.leading, 60)
                .padding(.trailing, 24)

                // Ghost Image
                Image("ghost")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .offset(x: -10, y: 20)
            }

            // Continue Button
            Button(action: onTap) {
                Text("Tap to continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
            }

            Spacer().frame(height: 40)
        }
        .background(
            Color.black.opacity(0.35) // 👈 subtle dim behind popup
                .ignoresSafeArea()
        )
    }
}

// MARK: - Preview
#Preview {
    GhostMessages(
        title: "Click on that object to clean it",
        onTap: {}
    )
}
