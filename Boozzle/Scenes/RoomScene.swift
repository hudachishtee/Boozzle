import SpriteKit
import SwiftUI

class RoomScene: SKScene {
    // These match what we call in RoomView
    var backgroundImage: String = "livingRoom-bg"
    var furnitureList: [Furniture] = []
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    func setupScene() {
        removeAllChildren()
        
        // 1. Add Background
        let bg = SKSpriteNode(imageNamed: backgroundImage)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        
        // Scale background to fit
        let aspect = bg.size.width / bg.size.height
        let sceneAspect = size.width / size.height
        
        if sceneAspect > aspect {
            bg.size = CGSize(width: size.width, height: size.width / aspect)
        } else {
            bg.size = CGSize(width: size.height * aspect, height: size.height)
        }
        
        addChild(bg)
        
        // 2. Add Furniture
        for item in furnitureList {
            let node = SKSpriteNode(imageNamed: item.currentImage)
            
            // Convert normalized position (0.0-1.0) to screen coordinates
            let x = item.position.x * size.width
            let y = item.position.y * size.height
            
            node.position = CGPoint(x: x, y: y)
            node.zPosition = item.zPosition
            node.setScale(item.scale) // Apply the furniture scale
            
            // Optional: Name the node so we can find it later if needed
            node.name = item.name
            
            addChild(node)
        }
    }
}
