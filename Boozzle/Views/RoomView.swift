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
    
    // We hold a reference to the scene so we can update it directly
    @State private var scene: RoomScene?
    
    private var furniture: [Furniture] {
        vm.getFurniture(for: roomType)
    }
    
    var body: some View {
        ZStack {
            // MARK: - GAME SCENE
            GeometryReader { geometry in
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
                    // ✅ THIS IS THE MAGIC LINE
                    // When 'lastUpdateTimestamp' changes (Buy/Clean), we update the scene instantly.
                    .onChange(of: vm.lastUpdateTimestamp) { _ in
                        scene?.updateFurniture(newFurniture: furniture)
                    }
            }
            
            VStack {
                // Top Bar
                HStack(alignment: .top) {
                    Button(action: { dismiss() }) {
                        Image("house-icon").resizable().frame(width: 50, height: 50)
                    }
                    .padding(12)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: -5) {
                            Text("\(vm.coins)").font(.title2).bold().foregroundColor(.white).shadow(color: .black, radius: 2)
                            Image("coin-icon").resizable().frame(width: 60, height: 60)
                        }
                        
                        // Shop Button (Only appears if room is clean)
                        if vm.isRoomFullyCleaned(roomType) {
                            Button { showFurnitureList = true } label: {
                                Image("shop-icon").resizable().scaledToFit().frame(width: 55, height: 55).shadow(color: .black.opacity(0.5), radius: 3)
                            }.transition(.scale)
                        }
                    }
                    .padding(.top, 10).padding(.trailing, 12)
                }
                Spacer()
                
                // Bottom Action Button
                HStack {
                    Spacer()
                    if vm.isRoomFullyCleaned(roomType) {
                        // Go to Coin Game
                        Button { navigateToGameCoins = true } label: {
                            Image("gamecoinsicon").resizable().scaledToFit().frame(width: 90, height: 90).shadow(color: .white.opacity(0.5), radius: 10).padding(20)
                        }
                    } else {
                        // Open Cleaning Menu
                        Button { showFurnitureList = true } label: {
                            Image("clean-icon").resizable().scaledToFit().frame(width: 80, height: 80).padding(20)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // MARK: - SHEETS & NAVIGATION
        .sheet(isPresented: $showFurnitureList) {
            FurnitureSheetView(
                roomType: roomType,
                viewModel: vm,
                selectedFurniture: $selectedFurniture,
                isShopMode: vm.isRoomFullyCleaned(roomType)
            )
            .onDisappear {
                // ✅ FORCE UPDATE when closing the shop
                vm.forceUpdate()
                
                // If they chose an item to clean, go to puzzle
                if selectedFurniture != nil && !vm.isRoomFullyCleaned(roomType) {
                    navigateToPuzzle = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPuzzle) {
            if let furnitureToClean = selectedFurniture {
                PuzzleConfirmationView(
                    room: roomType,
                    furniture: furnitureToClean,
                    shouldPopToRoot: $navigateToPuzzle
                )
                .onDisappear {
                    // ✅ FORCE UPDATE when returning from puzzle (Cleaning complete!)
                    vm.forceUpdate()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToGameCoins) {
            GameCoins().navigationBarBackButtonHidden(true)
        }
    }
    
    private func createScene(size: CGSize) -> RoomScene {
        // Reuse existing scene if possible to prevent flicker
        if let existingScene = scene {
            return existingScene
        }
        
        let newScene = RoomScene(size: size)
        newScene.scaleMode = .aspectFill
        newScene.backgroundImage = roomType.backgroundImage
        newScene.furnitureList = furniture
        
        // Save the scene so we can talk to it later
        DispatchQueue.main.async {
            self.scene = newScene
        }
        
        return newScene
    }
}
