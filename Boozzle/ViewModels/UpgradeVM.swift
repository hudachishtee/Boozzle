import Foundation
import Combine

class UpgradeVM: ObservableObject {
    @Published var coins: Int = 0 //why is this hardcoded? initially coins = 0 until they play puzzle
    @Published var furniture: [RoomType: [Furniture]] = [:]
    @Published var unlockedRooms: Set<RoomType> = [.livingRoom]  // Living room starts unlocked
    
    init() {
        // why ?
        furniture[.livingRoom] = Furniture.livingRoomFurniture
        furniture[.bedroom] = Furniture.bedroomFurniture
    }
    
    func getFurniture(for room: RoomType) -> [Furniture] {
        furniture[room] ?? []
    }
    
    func isRoomFullyCleaned(_ room: RoomType) -> Bool {
        getFurniture(for: room).allSatisfy { $0.isCleaned } //
    }
    
    var areAllRoomsCleaned: Bool {
        RoomType.allCases.allSatisfy { isRoomFullyCleaned($0) } //
    }
    
    // how
    func markFurnitureAsCleaned(room: RoomType, furnitureName: String) {
        guard var roomFurniture = furniture[room], //
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].isCleaned = true
        furniture[room] = roomFurniture
        
        if isRoomFullyCleaned(room) {
            unlockNextRoom(after: room)
        }
    }
    
    // Unlock the next room in sequence
    private func unlockNextRoom(after currentRoom: RoomType) {
        let allRooms = RoomType.allCases
        guard let currentIndex = allRooms.firstIndex(of: currentRoom),
              currentIndex + 1 < allRooms.count else { return }
        
        let nextRoom = allRooms[currentIndex + 1]
        unlockedRooms.insert(nextRoom)
    }
    
    func purchaseUpgrade(room: RoomType, furnitureName: String, upgradeIndex: Int) -> Bool {
        guard var roomFurniture = furniture[room],
              let furnitureIndex = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return false }
        
        let upgrade = roomFurniture[furnitureIndex].upgrades[upgradeIndex]
        
        guard coins >= upgrade.price else { return false }
        
        // Purchase and upgrade furniture
        coins -= upgrade.price
        roomFurniture[furnitureIndex].equippedUpgradeIndex = upgradeIndex
        furniture[room] = roomFurniture
        
        return true
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
    }
}
