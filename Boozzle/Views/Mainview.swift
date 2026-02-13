import SwiftUI

struct MainView: View {
    @State private var showSettings = false
    @EnvironmentObject var vm: UpgradeVM

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background first screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    VStack(spacing: 14) {
                        NavigationLink(destination: MapView()) {
                            Text("Play")
                        }
                        .buttonStyle(GameButtonStyle())
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Text("Settings")
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 120)
                }
            }
            // SETTINGS FOR MAIN: Simplified version
            .sheet(isPresented: $showSettings) {
                SettingsSheetView(
                    isMainMenu: true,
                    exitAction: { showSettings = false }
                )
                .presentationBackground(Color.clear)
            }
        }
    }
}

struct GameButtonStyle: ButtonStyle {
    private let buttonPurple = Color(red: 0x67/255, green: 0x2F/255, blue: 0x50/255)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Arial-Black", size: 26))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.45), radius: 1.2, x: 0, y: 1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Capsule().fill(buttonPurple.opacity(0.7)))
            .overlay(Capsule().stroke(buttonPurple.opacity(0.95), lineWidth: 2))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
