// PowerUpInfoOverlay.swift
import SwiftUI

struct PowerUpInstructions: View {
    let powerUpType: PowerUpType
    let colorShuffle: Color
    let colorRotate: Color
    let colorBomb: Color
    let onDismiss: () -> Void
    
    private var currentColor: Color {
        switch powerUpType {
        case .shuffle: return colorShuffle
        case .rotate: return colorRotate
        case .bomb: return colorBomb
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(currentColor)
                        .frame(width: 80, height: 80)
                    
                    Image(powerUpType.icon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .shadow(radius: 10)
                
                // Title
                Text(powerUpType.title)
                    .font(.custom("Arial-Black", size: 28))
                    .foregroundColor(.white)
                
                // Instruction
                Text(powerUpType.instruction)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Dismiss button
                Button("Got it") {
                    onDismiss()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 40)
                .background(Capsule().fill(currentColor))
                .foregroundColor(.white)
                .font(.headline)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0x2A/255, green: 0x1A/255, blue: 0x3C/255))
            )
            .frame(maxWidth: 320)
            .shadow(radius: 20)
        }
        .transition(.opacity)
    }
}

#Preview("Shuffle Power-Up") {
    PowerUpInstructions(
        powerUpType: .shuffle,
        colorShuffle: .colorButton,
        colorRotate: .green,
        colorBomb: .red,
        onDismiss: {}
    )
}

#Preview("Rotate Power-Up") {
    PowerUpInstructions(
        powerUpType: .rotate,
        colorShuffle: .colorButton,
        colorRotate: .green,
        colorBomb: .red,
        onDismiss: {}
    )
}

#Preview("Bomb Power-Up") {
    PowerUpInstructions(
        powerUpType: .bomb,
        colorShuffle: .colorButton,
        colorRotate: .green,
        colorBomb: .red,
        onDismiss: {}
    )
}
