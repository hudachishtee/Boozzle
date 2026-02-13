import SwiftUI

struct PuzzleConfirmationView: View {
    let room: RoomType
    let furniture: Furniture
    
    // ✅ Added: Controls navigation flow
    @Binding var shouldPopToRoot: Bool
    @EnvironmentObject var vm: UpgradeVM

    // Brand colors
    private let purple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let orange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let lightpurp = Color(red: 0x58/255, green: 0x2A/255, blue: 0x54/255)
    private let buttonPurple = Color(red: 0x67/255, green: 0x2F/255, blue: 0x50/255)

    var body: some View {
        ZStack {
            LinearGradient(colors: [purple, orange], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 40)

                Image("ghostie")
                    .resizable().scaledToFit().frame(height: 150)
                    .shadow(color: .black.opacity(0.25), radius: 6, y: 4)

                VStack(spacing: 16) {
                    Text("Item Selected")
                        .font(.custom("Arial-Black", size: 26))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 1, y: 1)

                    Image(furniture.uncleanImage)
                        .resizable().scaledToFit().frame(maxHeight: 180)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 6)
                }
                .padding(22)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(lightpurp.opacity(0.7))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(lightpurp.opacity(0.95), lineWidth: 4))
                )
                .padding(.horizontal, 28)

                // ✅ Navigation to Game
                // We pass the "onWin" logic here
                NavigationLink(destination: Game(
                    onWin: {
                        vm.markFurnitureAsCleaned(room: room, furnitureName: furniture.name)
                    },
                    shouldPopToRoot: $shouldPopToRoot
                )) {
                    Text("Play")
                        .font(.custom("Arial-Black", size: 26))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.45), radius: 1.2, x: 0, y: 1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Capsule().fill(buttonPurple.opacity(0.7)))
                        .overlay(Capsule().stroke(buttonPurple.opacity(0.95), lineWidth: 2))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}
