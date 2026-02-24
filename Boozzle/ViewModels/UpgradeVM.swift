import Foundation
import SwiftUI
import SwiftData
import Combine
@MainActor
class UpgradeVM: ObservableObject {
    @Published var coins: Int = 0
    @Published var furniture: [RoomType: [Furniture]] = [:]
    @Published var unlockedRooms: Set<RoomType> = [.livingRoom]
    @Published var lastUpdateTimestamp: Date = Date()
    
    // SwiftData Context
    private var container: ModelContainer?
    private var context: ModelContext?
    
    // The clean base versions of the rooms
    private let baseConfigurations: [RoomType: [Furniture]] = [
        .livingRoom: Furniture.livingRoomFurniture,
        .bedroom: Furniture.bedroomFurniture,
        .library: Furniture.libraryFurniture,
        .kitchen: Furniture.kitchenFurniture
    ]
    
    init() {
        do {
            container = try ModelContainer(for: PlayerSave.self, ItemSave.self)
            if let container = container {
                context = ModelContext(container)
            }
        } catch {
            print("SwiftData init failed.")
        }
        loadGameData()
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
    
    // MARK: - Game Actions
    func markFurnitureAsCleaned(room: RoomType, furnitureName: String) {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].isCleaned = true
        furniture[room] = roomFurniture
        
        saveItemProgress(room: room, item: roomFurniture[index]) // ✅ SwiftData
        
        if isRoomFullyCleaned(room) {
            unlockNextRoom(after: room)
        }
        forceUpdate()
    }
    
    private func unlockNextRoom(after currentRoom: RoomType) {
        switch currentRoom {
        case .livingRoom: unlockedRooms.insert(.bedroom)
        case .bedroom: unlockedRooms.insert(.library)
        case .library: unlockedRooms.insert(.kitchen)
        case .kitchen: break
        }
        savePlayerProgress() // ✅ SwiftData
    }
    
    func equipItem(room: RoomType, furnitureName: String, upgradeIndex: Int?) {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return }
        
        roomFurniture[index].equippedUpgradeIndex = upgradeIndex
        furniture[room] = roomFurniture
        
        saveItemProgress(room: room, item: roomFurniture[index]) // ✅ SwiftData
        forceUpdate()
    }
    
    func purchaseUpgrade(room: RoomType, furnitureName: String, upgradeIndex: Int) -> Bool {
        guard var roomFurniture = furniture[room],
              let index = roomFurniture.firstIndex(where: { $0.name == furnitureName }) else { return false }
        
        guard upgradeIndex >= 0 && upgradeIndex < roomFurniture[index].upgrades.count else { return false }
        
        if roomFurniture[index].ownedUpgradeIndices.contains(upgradeIndex) {
            equipItem(room: room, furnitureName: furnitureName, upgradeIndex: upgradeIndex)
            return true
        }
        
        let upgrade = roomFurniture[index].upgrades[upgradeIndex]
        guard coins >= upgrade.price else { return false }
        
        // Update Game State
        coins -= upgrade.price
        roomFurniture[index].ownedUpgradeIndices.insert(upgradeIndex)
        roomFurniture[index].equippedUpgradeIndex = upgradeIndex
        furniture[room] = roomFurniture
        
        // Save Both to SwiftData
        savePlayerProgress()
        saveItemProgress(room: room, item: roomFurniture[index])
        
        forceUpdate()
        return true
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        savePlayerProgress() // ✅ SwiftData
    }
    
    // MARK: - THE "RIGHT WAY" SWIFTDATA LOGIC
    
    private func savePlayerProgress() {
        guard let context = context else { return }
        let fetch = FetchDescriptor<PlayerSave>()
        
        if let saves = try? context.fetch(fetch), let playerSave = saves.first {
            playerSave.coins = self.coins
            playerSave.unlockedRooms = self.unlockedRooms.map { $0.rawValue }
        } else {
            let newSave = PlayerSave(coins: self.coins, unlockedRooms: self.unlockedRooms.map { $0.rawValue })
            context.insert(newSave)
        }
        try? context.save()
    }
    
    private func saveItemProgress(room: RoomType, item: Furniture) {
        guard let context = context else { return }
        let targetID = "\(room.rawValue)_\(item.name)"
        
        let fetch = FetchDescriptor<ItemSave>(predicate: #Predicate { $0.itemID == targetID })
        
        if let items = try? context.fetch(fetch), let existingItem = items.first {
            existingItem.isCleaned = item.isCleaned
            existingItem.ownedUpgrades = Array(item.ownedUpgradeIndices)
            existingItem.equippedUpgrade = item.equippedUpgradeIndex
        } else {
            let newItemSave = ItemSave(
                itemID: targetID,
                isCleaned: item.isCleaned,
                ownedUpgrades: Array(item.ownedUpgradeIndices),
                equippedUpgrade: item.equippedUpgradeIndex
            )
            context.insert(newItemSave)
        }
        try? context.save()
    }
    
    private func loadGameData() {
        guard let context = context else { return }
        
        // 1. Load the Player (Coins & Rooms)
        let playerFetch = FetchDescriptor<PlayerSave>()
        if let saves = try? context.fetch(playerFetch), let save = saves.first {
            self.coins = save.coins
            self.unlockedRooms = Set(save.unlockedRooms.compactMap { RoomType(rawValue: $0) })
        }
        
        // 2. Load Items & Apply them to the clean bases
        let itemFetch = FetchDescriptor<ItemSave>()
        let savedItems = (try? context.fetch(itemFetch)) ?? []
        
        // Convert array to a dictionary for super fast lookup
        let savedItemsDict = Dictionary(uniqueKeysWithValues: savedItems.map { ($0.itemID, $0) })
        
        var loadedFurniture: [RoomType: [Furniture]] = [:]
        
        for (room, baseItems) in baseConfigurations {
            var roomArray: [Furniture] = []
            
            for baseItem in baseItems {
                var activeItem = baseItem // Start clean
                let searchID = "\(room.rawValue)_\(baseItem.name)"
                
                // If we found a save file for this specific item, apply the progress!
                if let savedState = savedItemsDict[searchID] {
                    activeItem.isCleaned = savedState.isCleaned
                    activeItem.ownedUpgradeIndices = Set(savedState.ownedUpgrades)
                    activeItem.equippedUpgradeIndex = savedState.equippedUpgrade
                }
                roomArray.append(activeItem)
            }
            loadedFurniture[room] = roomArray
        }
        self.furniture = loadedFurniture
    }
}
