import SwiftUI
import SpriteKit

struct RoomView: View {
    let roomType: RoomType
    @EnvironmentObject var gameViewModel: UpgradeVM
    
    @State private var selectedFurniture: Furniture?
    @State private var showFurnitureList = false
    @State private var scene: RoomScene?
    
    private var furniture: [Furniture] {
            gameViewModel.getFurniture(for: roomType)
    }
    
    var body: some View {
        
        ZStack{
            GeometryReader { geometry in
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
            }
            
            VStack{
                HStack{
                    Button {
                        // navigate back to map. navigationDestination(mapView)
                    } label: {
                        Image("house-icon")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    .padding(12)
                    
                    Spacer()
                    
                    HStack(spacing: -10){
                            Text("\(gameViewModel.coins)") // show actual coin value
                                .foregroundColor(.white)

                            Image("coin-icon")
                                .resizable()
                                .frame(width: 80, height: 80)
                    }
                } // top navigation
                
                HStack{
                    Spacer()
                    // should only appear after all rooms have been cleaned
                    if gameViewModel.areAllRoomsCleaned {
                        // ghostPopupView(message) appears
                        
                        Button{
                            // navigates to puzzleView()
                        } label: {
                            Image("puzzle-icon")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .opacity(0.9)
                                .padding(20)
                        }
                    }
                }
                .padding(.top, -30)
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    Button{
                        showFurnitureList = true
                    } label: {
                        let cleanOrShopIcon = gameViewModel.areAllRoomsCleaned ? "shop-icon" : "clean-icon"
                        // should the funcitonality about whether furnitureListSheet will have clean mode or shop mode be added here?
                        Image(cleanOrShopIcon)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .opacity(0.9)
                            .padding(20)
                    }
                }//bottom
            }
            .navigationTitle(roomType.name)
            .sheet(isPresented: $showFurnitureList) {
                        FurnitureSheetView(
                            roomType: roomType,
                            viewModel: gameViewModel,
                            selectedFurniture: $selectedFurniture,
                            isShopMode: gameViewModel.areAllRoomsCleaned //shop mode only if all rooms cleaned
                        )
            }//sheet
        }//zstack
    }//body
        
    
    private func createScene(size: CGSize) -> RoomScene {
            if let existingScene = scene {
                return existingScene
            }
            
            let newScene = RoomScene(size: size)
            newScene.scaleMode = .aspectFill
            newScene.backgroundImage = roomType.backgroundImage
            newScene.furnitureList = furniture
            
            self.scene = newScene
            return newScene
        }
}// View

#Preview {
    RoomView(roomType: .bedroom)
        .environmentObject(UpgradeVM())
}
