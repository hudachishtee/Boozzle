import SwiftUI

struct FurnitureSheetView: View {
    let roomType: RoomType
    @ObservedObject var viewModel: UpgradeVM
    @Binding var selectedFurniture: Furniture?
    let isShopMode: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    private var furniture: [Furniture] {
        viewModel.getFurniture(for: roomType)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient for both modes
                LinearGradient(
                    colors: [Color(hex: "C24D32"), Color(hex: "481143")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    ForEach(furniture) { item in
                        FurnitureRow(
                            furniture: item,
                            isShopMode: isShopMode,
                            coins: viewModel.coins,
                            onCleanTap: {
                                // 1. Save which item we chose
                                selectedFurniture = item
                                // 2. Close the sheet (RoomView will handle the rest)
                                dismiss()
                            },
                            onPurchase: { upgradeIndex in
                                let success = viewModel.purchaseUpgrade(
                                    room: roomType,
                                    furnitureName: item.name,
                                    upgradeIndex: upgradeIndex
                                )
                                return success
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden) // Hide default list background
                .background(Color.clear)
            }
            .navigationTitle(isShopMode ? "Shop" : "Upgrade furniture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// ✅ Individual furniture row (Kept exactly as you designed)
struct FurnitureRow: View {
    let furniture: Furniture
    let isShopMode: Bool
    let coins: Int
    let onCleanTap: () -> Void
    let onPurchase: (Int) -> Bool
    
    @State private var selectedUpgradeIndex: Int = 0
    @State private var showPurchaseConfirmation = false
    @State private var selectedUpgrade: FurnitureUpgrade?
    
    var body: some View {
        HStack(spacing: 16) {
            // ✅ Furniture image
            if isShopMode && !furniture.upgrades.isEmpty {
                // Shop mode logic
                HStack(spacing: 8) {
                    Button(action: { previousVersion() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .disabled(selectedUpgradeIndex == 0)
                    .opacity(selectedUpgradeIndex == 0 ? 0.3 : 1.0)
                    
                    if selectedUpgradeIndex == 0 {
                        Image(furniture.cleanedImage)
                            .resizable().scaledToFit().frame(width: 80, height: 80)
                    } else {
                        Image(furniture.upgrades[selectedUpgradeIndex - 1].image)
                            .resizable().scaledToFit().frame(width: 80, height: 80)
                    }
                    
                    Button(action: { nextVersion() }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .disabled(selectedUpgradeIndex >= furniture.upgrades.count)
                    .opacity(selectedUpgradeIndex >= furniture.upgrades.count ? 0.3 : 1.0)
                }
                .frame(width: 120)
            } else {
                Image(furniture.currentImage)
                    .resizable().scaledToFit().frame(width: 80, height: 80)
            }
            
            Spacer()
            
            // ✅ Button (Clean or Buy)
            if isShopMode {
                shopButton
            } else {
                cleanButton
            }
        }
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .frame(height: 2)
                .foregroundColor(Color.white.opacity(0.3))
                .padding(.horizontal, -16),
            alignment: .bottom
        )
        .onAppear {
            if isShopMode && !furniture.upgrades.isEmpty {
                selectedUpgradeIndex = 1
            } else {
                selectedUpgradeIndex = 0
            }
        }
        .alert("Confirm Purchase", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                if let upgrade = selectedUpgrade,
                   let index = furniture.upgrades.firstIndex(where: { $0.id == upgrade.id }) {
                    _ = onPurchase(index)
                }
            }
        } message: {
            if let upgrade = selectedUpgrade {
                if coins < upgrade.price {
                    Text("Not enough coins! You need \(upgrade.price) but only have \(coins).")
                } else {
                    Text("Buy \(upgrade.name) for \(upgrade.price) coins?")
                }
            }
        }
    }
    
    // ✅ Clean button
    @ViewBuilder
    private var cleanButton: some View {
        if furniture.isCleaned {
            Text("Cleaned")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.2))
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        } else {
            Button("Clean") {
                onCleanTap()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.2))
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private var shopButton: some View {
        if furniture.upgrades.isEmpty ||
            (selectedUpgradeIndex == 0) ||
            (selectedUpgradeIndex > 0 && furniture.equippedUpgradeIndex == selectedUpgradeIndex - 1) {
            Text("Equipped")
                .font(.headline).foregroundColor(.white)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.green.opacity(0.3)).stroke(Color.green.opacity(0.5), lineWidth: 1))
        } else {
            let upgrade = furniture.upgrades[selectedUpgradeIndex - 1]
            let canAfford = coins >= upgrade.price
            
            Button("Buy \(upgrade.price)") {
                selectedUpgrade = upgrade
                showPurchaseConfirmation = true
            }
            .font(.headline).foregroundColor(.white)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 25).fill(canAfford ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3)).stroke(canAfford ? Color.blue.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1))
            .disabled(!canAfford)
        }
    }
    
    private func nextVersion() {
        if selectedUpgradeIndex < furniture.upgrades.count { selectedUpgradeIndex += 1 }
    }
    
    private func previousVersion() {
        if selectedUpgradeIndex > 0 { selectedUpgradeIndex -= 1 }
    }
}

// Helper for Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
