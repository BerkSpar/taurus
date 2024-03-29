//
//  CharacterNode.swift
//  taurus
//
//  Created by Felipe Passos on 20/03/24.
//

import SpriteKit

enum RotateType {
    case up
    case down
    case left
    case right
}

class CharacterNode: SKNode {
    var isRotating = false
    
    override init() {
        super.init()
        
        self.draw()
    }
    
    func draw() {
        let node = SKSpriteNode(imageNamed: "character")
        node.size = CGSize(width: 40, height: 40)
        node.zPosition = 10
        
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
       
        node.physicsBody?.categoryBitMask = PhysicsCategory.character
        node.physicsBody?.contactTestBitMask = PhysicsCategory.coin | PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = 0;
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        
        addChild(node)
    }
    
    func move() {
        if isRotating { return }
        
        let playerSpeed: CGFloat = 2.0
        let direction = zRotation + CGFloat.pi / 2
        
        let dx = playerSpeed * cos(direction)
        let dy = playerSpeed * sin(direction)
        
        position.x += dx
        position.y += dy
        
        if position.x > scene!.frame.width / 2 {
            position.x = -scene!.frame.width / 2
        }
        
        if position.x < -scene!.frame.width / 2 {
            position.x = scene!.frame.width / 2
        }
        
        if position.y > scene!.frame.height / 2 {
            position.y = -scene!.frame.height / 2
        }
        
        if position.y < -scene!.frame.height / 2 {
            position.y = scene!.frame.height / 2
        }
    }
    
    var lastRotation: RotateType = .up
    func rotate(_ type: RotateType) {
        if type == lastRotation { return }
        if isRotating { return }
        
        isRotating = true
        lastRotation = type
        var angle = 0.0
        
        switch type {
        case .up:
            angle = 0
        case .down:
            angle = .pi
        case .left:
            angle = .pi/2
        case .right:
            angle = -.pi/2
        }

        run(.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true)) {
            self.isRotating = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
