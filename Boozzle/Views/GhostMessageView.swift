//
//  GhostMessageView.swift
//  Boozzle
//
//  Created by Huda Chishtee on 13/02/2026.
//

import SwiftUI

struct GhostPopupView: View {

    // MARK: - Inputs (custom brick)
    let title: String
    let onTap: () -> Void

    var body: some View {
        ZStack {

            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "41235C"),
                    Color(hex: "C24D32")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Bubble + Ghost container
                ZStack(alignment: .bottomLeading) {

                    // Bubble container
                    ZStack {
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white)

                        // ✅ TEXT IS NOW INSIDE THE BUBBLE
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

                    // Ghost
                    Image("ghost")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .offset(x: -10, y: 20)
                }

                // Continue button
                Button(action: onTap) {
                    Text("Tap to continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                }

                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GhostPopupView(
        title: "Click on that object to clean it",
        onTap: {}
    )
}
