import SwiftUI
import SpriteKit

struct RoomView: View {
    let roomType: RoomType
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UpgradeVM
    
    @State private var selectedFurniture: Furniture?
    @State private var showFurnitureList = false
    @State private var navigateToPuzzle = false
    @State private var navigateToGameCoins = false
    @State private var scene: RoomScene?
    
    private var furniture: [Furniture] {
        vm.getFurniture(for: roomType)
    }
    
    var body: some View {
        ZStack {
            // 1. The Game Scene
            GeometryReader { geometry in
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
            }
            
            VStack {
                // 2. Top Bar
                HStack(alignment: .top) {
                    // Back Button (Top Left)
                    Button(action: { dismiss() }) {
                        Image("house-icon").resizable().frame(width: 50, height: 50)
                    }
                    .padding(12)
                    
                    Spacer()
                    
                    // Coins & Shop Container (Top Right)
                    VStack(alignment: .trailing, spacing: 8) {
                        // COINS
                        HStack(spacing: -5) {
                            Text("\(vm.coins)").font(.title2).bold().foregroundColor(.white)
                                .shadow(color: .black, radius: 2)
                            Image("coin-icon").resizable().frame(width: 60, height: 60)
                        }
                        
                        // ✅ SHOP ICON (Appears UNDER coins if room is clean)
                        if vm.isRoomFullyCleaned(roomType) {
                            Button {
                                showFurnitureList = true
                            } label: {
                                Image("shop-icon") // Ensure you have this asset
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 55, height: 55)
                                    .shadow(color: .black.opacity(0.5), radius: 3)
                            }
                            .transition(.scale)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 12)
                }
                
                Spacer()
                
                // 3. Bottom Main Button
                HStack {
                    Spacer()
                    
                    if vm.isRoomFullyCleaned(roomType) {
                        // ✅ CASE 1: Room Clean -> Show "gamecoinsicon"
                        Button {
                            navigateToGameCoins = true
                        } label: {
                            Image("gamecoinsicon") // Ensure you have this asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .shadow(color: .white.opacity(0.5), radius: 10)
                                .padding(20)
                        }
                    } else {
                        // ✅ CASE 2: Room Dirty -> Show "Clean" (Broom)
                        Button {
                            showFurnitureList = true
                        } label: {
                            Image("clean-icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .padding(20)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // Sheet for Furniture List
        .sheet(isPresented: $showFurnitureList) {
            FurnitureSheetView(
                roomType: roomType,
                viewModel: vm,
                selectedFurniture: $selectedFurniture,
                isShopMode: vm.isRoomFullyCleaned(roomType)
            )
            .onDisappear {
                // If selected item AND room NOT clean -> Go to Puzzle
                if selectedFurniture != nil && !vm.isRoomFullyCleaned(roomType) {
                    navigateToPuzzle = true
                }
            }
        }
        // Navigation to Puzzle (Cleaning)
        .navigationDestination(isPresented: $navigateToPuzzle) {
            if let furnitureToClean = selectedFurniture {
                PuzzleConfirmationView(
                    room: roomType,
                    furniture: furnitureToClean,
                    shouldPopToRoot: $navigateToPuzzle
                )
            }
        }
        // Navigation to Coin Game
        .navigationDestination(isPresented: $navigateToGameCoins) {
            GameCoins()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func createScene(size: CGSize) -> RoomScene {
        // Always recreate scene to ensure gold tint updates
        let newScene = RoomScene(size: size)
        newScene.scaleMode = .aspectFill
        newScene.backgroundImage = roomType.backgroundImage
        newScene.furnitureList = furniture
        self.scene = newScene
        return newScene
    }
}
