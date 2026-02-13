import Foundation
import Combine
import SwiftUI

class UpgradeVM: ObservableObject {
    @Published var coins: Int = 0
    @Published var furniture: [RoomType: [Furniture]] = [:]
    @Published var unlockedRooms: Set<RoomType> = [.livingRoom]
    
    // Timestamp to trigger UI updates in RoomView
    @Published var lastUpdateTimestamp: Date = Date()
    
    init() {
        furniture[.livingRoom] = Furniture.livingRoomFurniture
        furniture[.bedroom] = Furniture.bedroomFurniture
        
        // 🚨--- DEV HACK START ---🚨
        // Gives you 5000 coins and cleans everything instantly
        self.coins = 5000
        
        for room in RoomType.allCases {
            if var roomItems = furniture[room] {
                for i in 0..<roomItems.count {
                    roomItems[i].isCleaned = true
                }
                furniture[room] = roomItems
            }
        }
        // 🚨--- DEV HACK END ---🚨
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
    
    private func unlockNextRoom(after currentRoom: RoomType) {
        // Unlocking logic disabled for safe release if needed
        /*
        let allRooms = RoomType.allCases
        guard let currentIndex = allRooms.firstIndex(of: currentRoom),
              currentIndex + 1 < allRooms.count else { return }
        
        let nextRoom = allRooms[currentIndex + 1]
        unlockedRooms.insert(nextRoom)
        */
    }
    
    // ✅ EQUIP: Switch skin without buying
    func equipItem(room: RoomType, furnitureName: String, upgradeIndex: Int?) {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].equippedUpgradeIndex = upgradeIndex
        furniture[room] = roomFurniture
        forceUpdate()
    }
    
    // ✅ PURCHASE: Buy and Add to Owned List
    func purchaseUpgrade(room: RoomType, furnitureName: String, upgradeIndex: Int) -> Bool {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return false }
        
        guard upgradeIndex >= 0 && upgradeIndex < roomFurniture[index].upgrades.count else {
            return false
        }
        
        let upgrade = roomFurniture[index].upgrades[upgradeIndex]
        
        // If already owned, just equip
        if roomFurniture[index].ownedUpgradeIndices.contains(upgradeIndex) {
            equipItem(room: room, furnitureName: furnitureName, upgradeIndex: upgradeIndex)
            return true
        }
        
        guard coins >= upgrade.price else { return false }
        
        // Transaction
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
