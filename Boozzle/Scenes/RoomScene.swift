import SpriteKit

class RoomScene: SKScene {
    var backgroundImage: String = ""
    var furnitureList: [Furniture] = []
    
    // Scales furniture to look good on any screen
    private var furnitureScale: CGFloat {
        let referenceWidth: CGFloat = 393
        let scaleFactor = size.width / referenceWidth
        return min(max(scaleFactor, 1.0), 2.5)
    }
    
    override func didMove(to view: SKView) {
        refreshSceneContent()
    }
    
    // ✅ NEW: Call this to update furniture instantly!
    func updateFurniture(newFurniture: [Furniture]) {
        self.furnitureList = newFurniture
        refreshSceneContent()
    }
    
    private func refreshSceneContent() {
        removeAllChildren() // Clear old items
        addBackground()     // Re-add wall
        addFurniture()      // Re-add furniture (with new skins)
    }
    
    private func addBackground() {
        guard !backgroundImage.isEmpty else { return }
        
        let bg = SKSpriteNode(imageNamed: backgroundImage)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let scaleX = size.width / bg.size.width
        let scaleY = size.height / bg.size.height
        let baseScale = max(scaleX, scaleY)
        
        let aspectRatio = size.width / size.height
        let bgMultiplier: CGFloat = aspectRatio > 0.6 ? 2.5 : 2.0
        
        bg.setScale(baseScale * bgMultiplier)
        bg.zPosition = -1
        addChild(bg)
    }
    
    private func addFurniture() {
        for item in furnitureList {
            let sprite = SKSpriteNode(imageNamed: item.currentImage)
            
            sprite.position = CGPoint(
                x: size.width * item.position.x,
                y: size.height * item.position.y
            )
            sprite.zPosition = item.zPosition
            sprite.setScale(item.scale * furnitureScale)
            sprite.name = item.name
            
            // ✅ VISUALS: Turn it Gold if it's an Upgrade!
            if let equippedIndex = item.equippedUpgradeIndex, equippedIndex >= 0 {
                sprite.color = .yellow
                sprite.colorBlendFactor = 0.4
            } else {
                sprite.colorBlendFactor = 0.0
            }
            
            addChild(sprite)
        }
    }
}
