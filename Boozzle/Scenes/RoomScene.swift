import SpriteKit

class RoomScene: SKScene{
    var backgroundImage : String = ""
    var furnitureList: [Furniture] = []
    
    var onFurnitureClicked: ((Furniture) -> Void)?
    
    private var furnitureScale: CGFloat {
            let referenceWidth: CGFloat = 393
            let scaleFactor = size.width / referenceWidth
            return min(max(scaleFactor, 1.0), 2.5)
        }
    
    override func didMove(to view: SKView) {
            addBackground()
            addFurniture()
        }
    
    private func addBackground() {
        let bg = SKSpriteNode(imageNamed: backgroundImage)
            bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
            
            let scaleX = size.width / bg.size.width
            let scaleY = size.height / bg.size.height
            let baseScale = max(scaleX, scaleY)
            let aspectRatio = size.width / size.height
            let bgMultiplier: CGFloat
            
            if aspectRatio > 0.6 {
                bgMultiplier = 2.5
            } else {
                bgMultiplier = 2.0
            }
            
            bg.setScale(baseScale * bgMultiplier)
            bg.zPosition = -1
            addChild(bg)
        }
        
    private func addFurniture() {
        children.filter { $0.zPosition != -1 }.forEach { $0.removeFromParent() }
                
        for item in furnitureList {
            let sprite = SKSpriteNode(imageNamed: item.currentImage)
            
            sprite.position = CGPoint(
                x: size.width * item.position.x,
                y: size.height * item.position.y
            )
            sprite.zPosition = item.zPosition
            sprite.setScale(item.scale * furnitureScale)
            sprite.name = item.name
            
            // ✅ GOLD TINT LOGIC
            if item.equippedUpgradeIndex != nil {
                sprite.color = .yellow
                sprite.colorBlendFactor = 0.4
            } else {
                sprite.colorBlendFactor = 0.0
            }
            
            addChild(sprite)
        }
    }
    
    func refreshAllFurniture() {
        addFurniture()
    }
}
