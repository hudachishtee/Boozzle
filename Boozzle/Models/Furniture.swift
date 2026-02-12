import Foundation
struct Furniture: Identifiable {
    let id = UUID()
    let name: String
    let uncleanImage: String
    let cleanedImage: String
    var isCleaned: Bool = false
    
    let upgrades: [FurnitureUpgrade]
    var equippedUpgradeIndex: Int? = nil  // nil = using base clean version
    
    //position
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var zPosition: CGFloat = 1
    var scale: CGFloat = 1.0
    
    var currentImage: String {
            if !isCleaned {
                return uncleanImage  // Dirty
            } else if let upgradeIndex = equippedUpgradeIndex {
                return upgrades[upgradeIndex].image  // Upgraded
            } else {
                return cleanedImage  // Clean
            }
        }
}
struct FurnitureUpgrade: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let price: Int
}
extension Furniture {
    
    static let livingRoomFurniture: [Furniture] = [
        Furniture(name: "Sofa",
                    uncleanImage: "sofa-dirty",
                    cleanedImage: "sofa-clean",
                    upgrades: [
                        FurnitureUpgrade(name: "Luxury Sofa", image: "sofa-upgrade-1", price: 1000),
                        FurnitureUpgrade(name: "Golden Sofa", image: "sofa-upgrade-2", price: 2000)
                    ],
                    position: CGPoint(x: 0.3, y: 0.4),
                    zPosition: 2,
                    scale: 1.0),
        
        Furniture(name: "Fireplace",
                    uncleanImage: "fireplace-dirty",
                    cleanedImage: "fireplace-clean",
                    upgrades: [
                        FurnitureUpgrade(name: "Better fireplace", image: "fireplace-upgrade-1", price: 1500),
                    ],
                    position: CGPoint(x: 0.55, y: 0.5),
                    zPosition: 0,
                    scale: 1.0),
                
        Furniture(
                    name: "Table",
                    uncleanImage: "table-dirty",
                    cleanedImage: "table-clean",
                    upgrades: [],  // No upgrades available
                    position: CGPoint(x: 0.6, y: 0.36),
                    zPosition: 1,
                    scale: 0.5),
        
        Furniture(name: "carpet",
                  uncleanImage: "carpet-dirty",
                  cleanedImage: "carpet-clean",
                  upgrades: [],
                  position:CGPoint(x: 0.5, y: 0.25),
                 zPosition: 0,
                  scale: 1.2),
        
        Furniture(name: "frame",
                  uncleanImage: "frame-dirty",
                  cleanedImage: "frame-clean",
                  upgrades: [],
                  position:CGPoint(x: 0.5, y: 0.75),
                 zPosition: 1,
                  scale: 0.5)
    ]
    
    
    static let bedroomFurniture : [Furniture] = [
        Furniture(name: "bed",
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
                  upgrades: [],
                  position: CGPoint(x: 0.4, y: 0.67),
                  zPosition: 1,
                  scale: 0.5),
        
        Furniture(name: "bookshelf",
                  uncleanImage: "bookshelf-dirty",
                  cleanedImage: "bookshelf-clean",
                  upgrades: [],
                  position: CGPoint(x: 0.788, y: 0.35),
                  zPosition: 0,
                  scale: 0.55)
    ]
}
