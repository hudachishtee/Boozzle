import Foundation
import Combine
import SwiftUI

class UpgradeVM: ObservableObject {
    @Published var coins: Int = 0
    @Published var furniture: [RoomType: [Furniture]] = [:]
    @Published var unlockedRooms: Set<RoomType> = [.livingRoom]
    @Published var lastUpdateTimestamp: Date = Date()
    
    init() {
        // Load all rooms into the game memory
        furniture[.livingRoom] = Furniture.livingRoomFurniture
        furniture[.bedroom] = Furniture.bedroomFurniture
        furniture[.library] = Furniture.libraryFurniture
        furniture[.kitchen] = Furniture.kitchenFurniture
    }
    
    func forceUpdate() {
        lastUpdateTimestamp = Date()
    }
    
    func getFurniture(for room: RoomType) -> [Furniture] {
        furniture[room] ?? []
    }
    
    func isRoomFullyCleaned(_ room: RoomType) -> Bool {
        guard let items = furniture[room] else { return false }
        return items.allSatisfy { $0.isCleaned }
    }
    
    var areAllRoomsCleaned: Bool {
        RoomType.allCases.allSatisfy { isRoomFullyCleaned($0) }
    }
    
    func markFurnitureAsCleaned(room: RoomType, furnitureName: String) {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].isCleaned = true
        furniture[room] = roomFurniture
        
        if isRoomFullyCleaned(room) {
            unlockNextRoom(after: room)
        }
        forceUpdate()
    }
    
    // ✅ The completed logic to unlock rooms in sequence
    private func unlockNextRoom(after currentRoom: RoomType) {
        switch currentRoom {
        case .livingRoom:
            unlockedRooms.insert(.bedroom)
        case .bedroom:
            unlockedRooms.insert(.library)
        case .library:
            unlockedRooms.insert(.kitchen)
        case .kitchen:
            break // All rooms are fully unlocked!
        }
    }
    
    func equipItem(room: RoomType, furnitureName: String, upgradeIndex: Int?) {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].equippedUpgradeIndex = upgradeIndex
        furniture[room] = roomFurniture
        forceUpdate()
    }
    
    func purchaseUpgrade(room: RoomType, furnitureName: String, upgradeIndex: Int) -> Bool {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return false }
        
        guard upgradeIndex >= 0 && upgradeIndex < roomFurniture[index].upgrades.count else {
            return false
        }
        
        let upgrade = roomFurniture[index].upgrades[upgradeIndex]
        
        if roomFurniture[index].ownedUpgradeIndices.contains(upgradeIndex) {
            equipItem(room: room, furnitureName: furnitureName, upgradeIndex: upgradeIndex)
            return true
        }
        
        guard coins >= upgrade.price else { return false }
        
        coins -= upgrade.price
        roomFurniture[index].ownedUpgradeIndices.insert(upgradeIndex)
        roomFurniture[index].equippedUpgradeIndex = upgradeIndex
        
        furniture[room] = roomFurniture
        forceUpdate()
        return true
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
    }
}
