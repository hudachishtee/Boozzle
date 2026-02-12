//
//  Furniture.swift
//  Boozzle
//
//  Created by Huda Chishtee on 12/02/2026.
//

import Foundation

struct Furniture: Identifiable {
    let id = UUID()
    let name: String
    let uncleanImage: String // SVG Name
    let cleanedImage: String // SVG Name
    var isCleaned: Bool = false
    let targetScore: Int
    
    
    var position: CGPoint = CGPoint(x: 0.5, y: 0.5)   // Relative position (0.0 to 1.0)
    var zPosition: CGFloat = 1  // Layering
    var scale: CGFloat = 1.0    // Size mulitplier
}

extension Furniture {
    
    static let livingRoomFurniture: [Furniture] = [
        Furniture(name: "sofa",
                  uncleanImage: "sofa-dirty",
                  cleanedImage: "sofa-clean",
                  targetScore: 100,
                  position: CGPoint(x: 0.3, y: 0.4),
                 zPosition: 2),
        
        Furniture(name: "fireplace",
                  uncleanImage: "fireplace-dirty",
                  cleanedImage: "fireplace-clean",
                  targetScore: 100,
                  position:CGPoint(x: 0.5, y: 0.5),
                 zPosition: 0),
        
        Furniture(name: "table",
                  uncleanImage: "table-dirty",
                  cleanedImage: "table-clean",
                  targetScore: 100,
                  position:CGPoint(x: 0.6, y: 0.36),
                 zPosition: 1,
                  scale: 0.6),
        
        Furniture(name: "carpet",
                  uncleanImage: "carpet-dirty",
                  cleanedImage: "carpet-clean",
                  targetScore: 100,
                  position:CGPoint(x: 0.5, y: 0.25),
                 zPosition: 0,
                  scale: 1.2),
        
        Furniture(name: "frame",
                  uncleanImage: "frame-dirty",
                  cleanedImage: "frame-clean",
                  targetScore: 100,
                  position:CGPoint(x: 0.5, y: 0.75),
                 zPosition: 1,
                  scale: 0.5)
    ]
    
    
    static let bedroomFurniture : [Furniture] = [
        Furniture(name: "bed",
                  uncleanImage: "bed-dirty",
                  cleanedImage: "bed-clean",
                  targetScore: 100,
                  position: CGPoint(x: 0.4, y: 0.37),
                  zPosition: 1,
                  scale: 1.0),
        
        Furniture(name: "chandelier",
                  uncleanImage: "chandelier-dirty",
                  cleanedImage: "chandelier-clean",
                  targetScore: 100,
                  position: CGPoint(x: 0.4, y: 0.67),
                  zPosition: 1,
                  scale: 0.5),
        
        Furniture(name: "bookshelf",
                  uncleanImage: "bookshelf-dirty",
                  cleanedImage: "bookshelf-clean",
                  targetScore: 100,
                  position: CGPoint(x: 0.788, y: 0.35),
                  zPosition: 0,
                  scale: 0.55)
    ]
}
