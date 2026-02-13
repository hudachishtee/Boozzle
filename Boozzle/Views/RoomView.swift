import SwiftUI
import SpriteKit

struct RoomView: View {
    let roomType: RoomType
    @Environment(\.dismiss) var dismiss // Added to fix navigation back to Map
    @EnvironmentObject var vm: UpgradeVM
    
    @State private var selectedFurniture: Furniture?
    @State private var showFurnitureList = false
    @State private var navigateToPuzzle = false
    @State private var scene: RoomScene?
    
    private var furniture: [Furniture] {
        vm.getFurniture(for: roomType)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    // FIXED: Replaced NavigationLink with dismiss button
                    Button(action: {
                        dismiss() // Strictly goes back to MapView
                    }) {
                        Image("house-icon").resizable().frame(width: 60, height: 60)
                    }
                    .padding(12)
                    
                    Spacer()
                    
                    HStack(spacing: -10) {
                        Text("\(vm.coins)").font(.title).bold().foregroundColor(.white)
                        Image("coin-icon").resizable().frame(width: 80, height: 80)
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button {
                        showFurnitureList = true
                    } label: {
                        let icon = vm.isRoomFullyCleaned(roomType) ? "shop-icon" : "clean-icon"
                        Image(icon).resizable().frame(width: 60, height: 60).padding(20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showFurnitureList) {
            FurnitureSheetView(
                roomType: roomType,
                viewModel: vm,
                selectedFurniture: $selectedFurniture,
                isShopMode: vm.isRoomFullyCleaned(roomType)
            )
            .onDisappear {
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
            }
        }
    }
    
    private func createScene(size: CGSize) -> RoomScene {
        if let existingScene = scene { return existingScene }
        let newScene = RoomScene(size: size)
        newScene.scaleMode = .aspectFill
        newScene.backgroundImage = roomType.backgroundImage
        newScene.furnitureList = furniture
        self.scene = newScene
        return newScene
    }
}
