import SpriteKit

class RoomScene: SKScene {
    var backgroundImage: String = ""
    var furnitureList: [Furniture] = []
    
    private var furnitureScale: CGFloat {
        let referenceWidth: CGFloat = 393
        let scaleFactor = size.width / referenceWidth
        return min(max(scaleFactor, 1.0), 2.5)
    }
    
    override func didMove(to view: SKView) {
        refreshSceneContent()
    }
    
    func updateFurniture(newFurniture: [Furniture]) {
        self.furnitureList = newFurniture
        refreshSceneContent()
    }
    
    private func refreshSceneContent() {
        removeAllChildren()
        addBackground()
        addFurniture()
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
            sprite.name = item.name
            
            var finalScale = item.scale * furnitureScale
            
            if item.equippedUpgradeIndex != nil {
                finalScale = finalScale * 0.25
            }
            
            sprite.setScale(finalScale)
            
            addChild(sprite)
        }
    }
}
