import Foundation
import SwiftUI

struct Furniture: Identifiable {
    let id = UUID()
    let name: String
    let uncleanImage: String
    let cleanedImage: String
    var isCleaned: Bool = false
    
    let upgrades: [FurnitureUpgrade]
    
    var ownedUpgradeIndices: Set<Int> = []
    
    var equippedUpgradeIndex: Int? = nil
    
    var position: CGPoint
    var zPosition: CGFloat = 1
    var scale: CGFloat = 1.0
    
    var currentImage: String {
        if !isCleaned {
            return uncleanImage
        } else if let upgradeIndex = equippedUpgradeIndex {
            if upgradeIndex < upgrades.count {
                return upgrades[upgradeIndex].image
            }
            return cleanedImage
        } else {
            return cleanedImage
        }
    }
    
    static let livingRoomFurniture: [Furniture] = [
        Furniture(name: "Sofa", uncleanImage: "sofa-dirty", cleanedImage: "sofa-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Sofa", image: "sofa-gold", price: 1000)
                  ], position: CGPoint(x: 0.3, y: 0.4), zPosition: 2, scale: 1.0),
        
        Furniture(name: "Fireplace", uncleanImage: "fireplace-dirty", cleanedImage: "fireplace-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Fireplace", image: "fireplace-gold", price: 1500)
                  ], position: CGPoint(x: 0.55, y: 0.5), zPosition: 0, scale: 1.0),
                  
        Furniture(name: "Table", uncleanImage: "table-dirty", cleanedImage: "table-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Table", image: "table-gold", price: 1200)
                  ], position: CGPoint(x: 0.6, y: 0.36), zPosition: 1, scale: 0.6),

        Furniture(name: "Carpet", uncleanImage: "carpet-dirty", cleanedImage: "carpet-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Carpet", image: "carpet-gold", price: 1000)
                  ], position: CGPoint(x: 0.5, y: 0.25), zPosition: 0, scale: 1.2),
        
        Furniture(name: "Frame", uncleanImage: "frame-dirty", cleanedImage: "frame-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Frame", image: "frame-gold", price: 1500)
                  ], position: CGPoint(x: 0.5, y: 0.75), zPosition: 1, scale: 0.5)
    ]
    
    static let bedroomFurniture: [Furniture] = [
        Furniture(name: "Bed", uncleanImage: "bed-dirty", cleanedImage: "bed-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Bed", image: "bed-gold", price: 1500)
                  ], position: CGPoint(x: 0.4, y: 0.37), zPosition: 1, scale: 1.0),

        Furniture(name: "Chandelier", uncleanImage: "chandelier-dirty", cleanedImage: "chandelier-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Chandelier", image: "chandelier-gold", price: 1200)
                  ], position: CGPoint(x: 0.4, y: 0.67), zPosition: 1, scale: 0.5),
        
        Furniture(name: "Bookshelf", uncleanImage: "bookshelf-dirty", cleanedImage: "bookshelf-clean",
                  upgrades: [
                    FurnitureUpgrade(name: "Golden Bookshelf", image: "bookshelf-gold", price: 1000)
                  ], position: CGPoint(x: 0.788, y: 0.35), zPosition: 0, scale: 0.55)
    ]
}

struct FurnitureUpgrade: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let price: Int
}

enum RoomType: CaseIterable {
    case livingRoom, bedroom
    var name: String { switch self { case .livingRoom: return "Living Room"; case .bedroom: return "Bedroom" } }
    var backgroundImage: String { switch self { case .livingRoom: return "livingRoom-bg"; case .bedroom: return "bedroom-bg-clean" } }
}
