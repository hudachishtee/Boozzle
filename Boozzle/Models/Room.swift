import Foundation

struct Room: Identifiable {
    let id: UUID
    let name: String
    let backgroundImage: String   // The empty room SVG
    var isLocked: Bool
    var furnitureItems: [Furniture]
    
    // Computed property to tell the GameView if we can go to the next room
    var isFullyCleaned: Bool {
        furnitureItems.allSatisfy { $0.isCleaned } // make this simple
    }
}

enum RoomType : CaseIterable {
    case livingRoom
    case bedroom
    
    var backgroundImage: String {
        switch self {
        case .livingRoom: return "livingRoom-bg"
        case .bedroom: return "bedroom-bg-clean"
        }
    }
    
    var furniture: [Furniture] {
        switch self {
        case .livingRoom: return Furniture.livingRoomFurniture
        case .bedroom: return Furniture.bedroomFurniture
        }
    }
    
    var name: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .bedroom: return "Bedroom"
        }
    }
}
