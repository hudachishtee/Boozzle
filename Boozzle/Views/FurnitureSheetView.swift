import SwiftUI

struct FurnitureSheetView: View {
    let roomType: RoomType
    @ObservedObject var viewModel: UpgradeVM
    @Binding var selectedFurniture: Furniture?
    let isShopMode: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemToBuy: Furniture? = nil
    @State private var upgradeIndexToBuy: Int? = nil
    
    private var furniture: [Furniture] {
        viewModel.getFurniture(for: roomType)
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "C24D32"), Color(hex: "481143")],
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()
                    
                    List {
                        ForEach(furniture) { item in
                            FurnitureRow(
                                furniture: item,
                                isShopMode: isShopMode,
                                onCleanTap: {
                                    selectedFurniture = item
                                    dismiss()
                                },
                                onRequestPurchase: { index in
                                    itemToBuy = item
                                    upgradeIndexToBuy = index
                                },
                                onEquip: { index in
                                    let realIndex = index == 0 ? nil : (index - 1)
                                    viewModel.equipItem(room: roomType, furnitureName: item.name, upgradeIndex: realIndex)
                                }
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle(isShopMode ? "Shop" : "Upgrade furniture")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
            }
            
            // THE CUSTOM IN-GAME POPUP
            if let item = itemToBuy, let upIndex = upgradeIndexToBuy {
                if upIndex >= 0 && upIndex < item.upgrades.count {
                    let upgrade = item.upgrades[upIndex]
                    let canAfford = viewModel.coins >= upgrade.price
                    
                    ZStack {
                        Color.black.opacity(0.7).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text("Buy \(upgrade.name)?")
                                .font(.custom("Arial-Black", size: 22))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 8) {
                                Image("coin").resizable().frame(width: 35, height: 35)
                                Text("\(upgrade.price)")
                                    .font(.title).bold()
                                    .foregroundColor(.yellow)
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    itemToBuy = nil
                                    upgradeIndexToBuy = nil
                                }) {
                                    Text("Cancel")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 45)
                                        .background(Capsule().fill(Color.red.opacity(0.9)))
                                }
                                
                                Button(action: {
                                    let success = viewModel.purchaseUpgrade(room: roomType, furnitureName: item.name, upgradeIndex: upIndex)
                                    if success {
                                        itemToBuy = nil
                                        upgradeIndexToBuy = nil
                                        dismiss()
                                    }
                                }) {
                                    Text("Buy")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 100, height: 45)
                                        .background(Capsule().fill(canAfford ? Color.green.opacity(0.9) : Color.gray))
                                }
                                .disabled(!canAfford)
                            }
                        }
                        .padding(30)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color(hex: "582A54")))
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.6), lineWidth: 3))
                        .shadow(color: .black.opacity(0.6), radius: 10, y: 5)
                        .padding(.horizontal, 40)
                    }
                    .zIndex(100)
                }
            }
        }
    }
}

struct FurnitureRow: View {
    let furniture: Furniture
    let isShopMode: Bool
    let onCleanTap: () -> Void
    let onRequestPurchase: (Int) -> Void
    let onEquip: (Int) -> Void
    
    @State private var selectedUpgradeIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // IMAGE AREA
            if isShopMode && !furniture.upgrades.isEmpty {
                HStack(spacing: 8) {
                    Button(action: { if selectedUpgradeIndex > 0 { selectedUpgradeIndex -= 1 } }) {
                        Image(systemName: "chevron.left").foregroundColor(.white).font(.title2)
                    }
                    .buttonStyle(.plain) // ✅ FIX: Prevents SwiftUI click bug
                    .disabled(selectedUpgradeIndex == 0)
                    .opacity(selectedUpgradeIndex == 0 ? 0.3 : 1.0)
                    
                    ZStack {
                        if selectedUpgradeIndex == 0 {
                            Image(furniture.cleanedImage).resizable().scaledToFit().frame(width: 80, height: 80)
                        } else {
                            Image(furniture.cleanedImage).resizable().scaledToFit().frame(width: 80, height: 80).colorMultiply(.yellow)
                        }
                    }
                    
                    Button(action: { if selectedUpgradeIndex < furniture.upgrades.count { selectedUpgradeIndex += 1 } }) {
                        Image(systemName: "chevron.right").foregroundColor(.white).font(.title2)
                    }
                    .buttonStyle(.plain) // ✅ FIX
                    .disabled(selectedUpgradeIndex >= furniture.upgrades.count)
                    .opacity(selectedUpgradeIndex >= furniture.upgrades.count ? 0.3 : 1.0)
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
                if furniture.isCleaned {
                    Text("Cleaned").font(.headline).foregroundColor(.white).padding(12).background(Capsule().stroke(Color.white, lineWidth: 1))
                } else {
                    Button("Clean") { onCleanTap() }
                        .buttonStyle(.plain) // ✅ FIX
                        .font(.headline).foregroundColor(.white).padding(12).background(Capsule().stroke(Color.white, lineWidth: 1))
                }
            }
        }
        .padding(.vertical, 12)
        .overlay(Rectangle().frame(height: 2).foregroundColor(Color.white.opacity(0.3)).padding(.horizontal, -16), alignment: .bottom)
        .onAppear { selectedUpgradeIndex = 0 }
    }
    
    @ViewBuilder
    private var shopButton: some View {
        let currentEquippedIndex = furniture.equippedUpgradeIndex ?? -1
        let isCurrentItemEquipped = (selectedUpgradeIndex == 0 && currentEquippedIndex == -1) ||
                                    (selectedUpgradeIndex > 0 && currentEquippedIndex == (selectedUpgradeIndex - 1))
        
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
            .buttonStyle(.plain) // ✅ FIX
            .font(.headline).foregroundColor(.white)
            .padding(12)
            .background(Capsule().fill(Color.blue.opacity(0.8)))
        } else {
            if selectedUpgradeIndex > 0 {
                Button("Buy") {
                    onRequestPurchase(selectedUpgradeIndex - 1)
                }
                .buttonStyle(.plain) // ✅ FIX: This makes the "Buy" button actually work instead of clicking the left arrow!
                .font(.headline).foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.blue.opacity(0.8)))
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
