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
                                selectedFurniture = item
                                dismiss()
                            },
                            onPurchase: { upgradeIndex in
                                return viewModel.purchaseUpgrade(room: roomType, furnitureName: item.name, upgradeIndex: upgradeIndex)
                            },
                            onEquip: { upgradeIndex in
                                // 0 = Base (Clean), >0 = Upgrade
                                let realIndex = upgradeIndex == 0 ? nil : (upgradeIndex - 1)
                                viewModel.equipItem(room: roomType, furnitureName: item.name, upgradeIndex: realIndex)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle(isShopMode ? "Shop" : "Upgrade furniture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

struct FurnitureRow: View {
    let furniture: Furniture
    let isShopMode: Bool
    let coins: Int
    let onCleanTap: () -> Void
    let onPurchase: (Int) -> Bool
    let onEquip: (Int) -> Void
    
    @State private var selectedUpgradeIndex: Int = 0
    @State private var showPurchaseConfirmation = false
    
    var body: some View {
        HStack(spacing: 16) {
            // IMAGE AREA
            if isShopMode && !furniture.upgrades.isEmpty {
                HStack(spacing: 8) {
                    // Left Arrow
                    Button(action: { if selectedUpgradeIndex > 0 { selectedUpgradeIndex -= 1 } }) {
                        Image(systemName: "chevron.left").foregroundColor(.white).font(.title2)
                    }
                    .disabled(selectedUpgradeIndex == 0)
                    .opacity(selectedUpgradeIndex == 0 ? 0.3 : 1.0)
                    
                    ZStack {
                        if selectedUpgradeIndex == 0 {
                            Image(furniture.cleanedImage)
                                .resizable().scaledToFit().frame(width: 80, height: 80)
                        } else {
                            Image(furniture.cleanedImage)
                                .resizable().scaledToFit().frame(width: 80, height: 80)
                                .colorMultiply(.yellow) // Gold Tint
                        }
                    }
                    
                    // Right Arrow (Limit to 1 Upgrade max)
                    Button(action: { if selectedUpgradeIndex < furniture.upgrades.count { selectedUpgradeIndex += 1 } }) {
                        Image(systemName: "chevron.right").foregroundColor(.white).font(.title2)
                    }
                    .disabled(selectedUpgradeIndex >= 1)
                    .opacity(selectedUpgradeIndex >= 1 ? 0.3 : 1.0)
                }
                .frame(width: 150)
            } else {
                Image(furniture.currentImage).resizable().scaledToFit().frame(width: 80, height: 80)
            }
            
            Spacer()
            
            // BUTTON AREA
            if isShopMode {
                shopButton
            } else {
                cleanButton
            }
        }
        .padding(.vertical, 12)
        .overlay(Rectangle().frame(height: 2).foregroundColor(Color.white.opacity(0.3)).padding(.horizontal, -16), alignment: .bottom)
        .onAppear { selectedUpgradeIndex = 0 }
        
        // ✅ SAFE ALERT
        .alert("Confirm Purchase", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                _ = onPurchase(selectedUpgradeIndex - 1)
            }
        } message: {
            // 🛑 SAFETY CHECK: Ensure index exists before reading price
            if selectedUpgradeIndex > 0, (selectedUpgradeIndex - 1) < furniture.upgrades.count {
                let price = furniture.upgrades[selectedUpgradeIndex - 1].price
                Text("Buy for \(price) coins?")
            } else {
                Text("Confirm purchase?")
            }
        }
    }
    
    @ViewBuilder
    private var cleanButton: some View {
        if furniture.isCleaned {
            Text("Cleaned").font(.headline).foregroundColor(.white).padding(12).background(Capsule().stroke(Color.white, lineWidth: 1))
        } else {
            Button("Clean") { onCleanTap() }
                .font(.headline).foregroundColor(.white).padding(12).background(Capsule().stroke(Color.white, lineWidth: 1))
        }
    }
    
    @ViewBuilder
    private var shopButton: some View {
        let currentEquippedIndex = furniture.equippedUpgradeIndex ?? -1
        // Check if currently showing item is equipped
        let isCurrentItemEquipped = (selectedUpgradeIndex == 0 && currentEquippedIndex == -1) ||
                                    (selectedUpgradeIndex > 0 && currentEquippedIndex == (selectedUpgradeIndex - 1))
        
        // Check ownership
        let isOwned: Bool = {
            if selectedUpgradeIndex == 0 { return true }
            return furniture.ownedUpgradeIndices.contains(selectedUpgradeIndex - 1)
        }()
        
        if isCurrentItemEquipped {
            Text("Equipped")
                .font(.headline).foregroundColor(.white)
                .padding(12)
                .background(Capsule().fill(Color.green.opacity(0.6)))
        } else if isOwned {
            Button("Equip") {
                onEquip(selectedUpgradeIndex)
            }
            .font(.headline).foregroundColor(.white)
            .padding(12)
            .background(Capsule().fill(Color.blue.opacity(0.8)))
        } else {
            // SAFE PRICE DISPLAY
            if selectedUpgradeIndex > 0, (selectedUpgradeIndex - 1) < furniture.upgrades.count {
                let upgrade = furniture.upgrades[selectedUpgradeIndex - 1]
                let canAfford = coins >= upgrade.price
                
                Button("\(upgrade.price)") {
                    showPurchaseConfirmation = true
                }
                .font(.headline).foregroundColor(.white)
                .padding(12)
                .background(Capsule().fill(canAfford ? Color.blue.opacity(0.6) : Color.gray))
                .disabled(!canAfford)
            } else {
                Text("Error").font(.caption).foregroundColor(.red)
            }
        }
    }
}

// MARK: - Color Hex Helper
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
