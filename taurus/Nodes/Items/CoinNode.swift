//
//  CoinNode.swift
//  taurus
//
//  Created by Felipe Passos on 20/03/24.
//

import SpriteKit

class CoinNode: SKNode, Item {
    let id = "coin"
    
    let spawnTimeRange: ClosedRange<TimeInterval>
    let levelRange: ClosedRange<Int>
    let pointsRange: ClosedRange<Int>
    let velocityRange: ClosedRange<Double>
    
    let velocity: Double
    let points: Int
    
    init(spawnTimeRange: ClosedRange<TimeInterval>, levelRange: ClosedRange<Int>, pointsRange: ClosedRange<Int>, velocityRange: ClosedRange<Double>) {
        self.spawnTimeRange = spawnTimeRange
        self.levelRange = levelRange
        self.pointsRange = pointsRange
        self.velocityRange = velocityRange
        
        self.velocity = Double.random(in: velocityRange)
        self.points = Int.random(in: pointsRange)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clone() -> any Item {
        CoinNode(spawnTimeRange: spawnTimeRange, levelRange: levelRange, pointsRange: pointsRange, velocityRange: velocityRange)
    }
    
    public func follow(_ scene: GameScene) {
        removeAllActions()
        
        let followPlayer = SKAction.customAction(withDuration: TimeInterval(Int.max), actionBlock: {
            (node,elapsedTime) in
            let dx = scene.character.position.x - node.position.x
            let dy = scene.character.position.y - node.position.y
            let angle = atan2(dx,dy)
            node.position.x += sin(angle) * 2
            node.position.y += cos(angle) * 2
        })
        
        run(followPlayer)
    }
    
    func draw() -> SKNode {
        let node = SKSpriteNode(imageNamed: "yellow_coin")
        node.size = CGSize(width: 20, height: 20)
        node.glow()
        node.glow()
        
        physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        
        addChild(node)
        
        return node.copy() as! SKNode
    }
    
    func configureCollision() {
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        
        physicsBody?.contactTestBitMask = PhysicsCategory.character
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.collisionBitMask = 0;
    }
    
    var didContacted = false
    func didContact(_ scene: GameScene, _ contact: SKPhysicsContact) {
        let contactNode = contact.bodyA.node is CoinNode ? contact.bodyB.node : contact.bodyA.node
                
        if contactNode is Barrier { return }
        if contactNode is Captalist { return }
        if contactNode is CharacterBulletNode { return }
        
        if didContacted { return }
        
        didContacted = true
        
        let label = SKLabelNode(
            attributedText: NSAttributedString(
              string: "+\(points)",
              attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .black),
                .foregroundColor : UIColor.neonYellow,
                .strokeWidth : -5,
              ]
            )
          )
        label.glow()
        label.position = contact.contactPoint
        
        scene.addChild(label)
        
        label.run(.sequence([
            .group([
                .fadeOut(withDuration: 1),
                .move(by: CGVector(dx: 0, dy: 20), duration: 1)
            ]),
            .removeFromParent()
        ]))
        
        GameController.shared.points += points
        
        HapticsService.shared.play(.soft)
        
        run(.sequence([
            .move(to: scene.coins.position, duration: 0.5),
            .removeFromParent(),
            .run {
                scene.updatePoints()
            }
        ]))
    }
    
    func spawn(_ scene: GameScene) {
        let xPosition = Double.random(in: -scene.frame.width/2 ... scene.frame.width/2)
        let yPosition = (scene.frame.height / 2)
        
        position.y = yPosition
        position.x = xPosition
        
        scene.addChild(self)
        
        run(.sequence([
            .move(to: CGPoint(x: position.x, y: -500), duration: velocity),
            .removeFromParent()
        ]))
    }
}
