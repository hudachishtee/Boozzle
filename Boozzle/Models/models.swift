import Foundation
import SwiftUI

// MARK: - Furniture Models
struct Furniture: Identifiable {
    let id = UUID()
    let name: String
    let uncleanImage: String
    let cleanedImage: String
    var isCleaned: Bool = false
    
    let upgrades: [FurnitureUpgrade]
    var equippedUpgradeIndex: Int? = nil  // nil = using base clean version
    
    // Position (Normalized 0.0 to 1.0)
    var position: CGPoint
    var zPosition: CGFloat = 1
    var scale: CGFloat = 1.0
    
    var currentImage: String {
        if !isCleaned {
            return uncleanImage  // Dirty
        } else if let upgradeIndex = equippedUpgradeIndex {
            // Safety check: make sure index is valid
            if upgradeIndex < upgrades.count {
                return upgrades[upgradeIndex].image
            }
            return cleanedImage
        } else {
            return cleanedImage  // Clean
        }
    }
    
    // DATA: Living Room
    static let livingRoomFurniture: [Furniture] = [
        Furniture(name: "Sofa",
                  uncleanImage: "sofa-dirty",
                  cleanedImage: "sofa-clean",
                  upgrades: [
                      FurnitureUpgrade(name: "Antique Sofa", image: "sofa-upgrade-1", price: 1000),
                  ],
                  position: CGPoint(x: 0.3, y: 0.4),
                  zPosition: 2,
                  scale: 1.0),
        
        Furniture(name: "Fireplace",
                  uncleanImage: "fireplace-dirty",
                  cleanedImage: "fireplace-clean",
                  upgrades: [
                      FurnitureUpgrade(name: "Royal Fireplace", image: "fireplace-upgrade-1", price: 1500)
                  ],
                  position: CGPoint(x: 0.55, y: 0.5),
                  zPosition: 0,
                  scale: 1.0),
                  
        Furniture(name: "Table",
                  uncleanImage: "table-dirty",
                  cleanedImage: "table-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "sparkle it", image: "table-upgrade-1", price: 2500)],
                  position: CGPoint(x: 0.6, y: 0.36),
                  zPosition: 1,
                  scale: 0.6),

        Furniture(name: "carpet",
                  uncleanImage: "carpet-dirty",
                  cleanedImage: "carpet-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "square", image: "carpet-upgrade-1", price: 2500)],
                  position:CGPoint(x: 0.5, y: 0.25),
                 zPosition: 0,
                  scale: 1.2),
        
        Furniture(name: "frame",
                  uncleanImage: "frame-dirty",
                  cleanedImage: "frame-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "pink frame", image: "frame-upgrade-1", price: 2500),
                    FurnitureUpgrade(name: "red frame", image: "frame-upgrade-2", price: 2500)],
                  position:CGPoint(x: 0.5, y: 0.75),
                 zPosition: 1,
                  scale: 0.5)
    ]
    
    // DATA: Bedroom
    static let bedroomFurniture: [Furniture] = [
        Furniture(name: "Bed",
                  uncleanImage: "bed-dirty",
                  cleanedImage: "bed-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Royal Bed", image: "bed-upgrade-1", price: 2500)
                  ],
                  position: CGPoint(x: 0.4, y: 0.37),
                  zPosition: 1,
                  scale: 1.0),

        Furniture(name: "chandelier",
                  uncleanImage: "chandelier-dirty",
                  cleanedImage: "chandelier-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "better chandelier", image: "chandelier-upgrade-1", price: 2500)],
                  position: CGPoint(x: 0.4, y: 0.67),
                  zPosition: 1,
                  scale: 0.5),
        
        Furniture(name: "bookshelf",
                  uncleanImage: "bookshelf-dirty",
                  cleanedImage: "bookshelf-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Royal Bed", image: "bookshelf-upgrade-1", price: 2500)],
                  position: CGPoint(x: 0.788, y: 0.35),
                  zPosition: 0,
                  scale: 0.55)
    ]
}

struct FurnitureUpgrade: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let price: Int
}


// MARK: - Room Models
enum RoomType: CaseIterable {
    case livingRoom
    case bedroom
    
    var name: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .bedroom: return "Bedroom"
        }
    }
    
    var backgroundImage: String {
        switch self {
        case .livingRoom: return "livingRoom-bg"
        case .bedroom: return "bedroom-bg-clean"
        }
    }

// check if this could be neeeded:
//    var furniture: [Furniture] {
//        switch self {
//        case .livingRoom: return Furniture.livingRoomFurniture
//        case .bedroom: return Furniture.bedroomFurniture
//        }
//    }
    
}
