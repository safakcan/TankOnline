//
//  Bullet.swift
//  Tank Online
//
//  Created by Can Bas on 3/18/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import SpriteKit
import GameplayKit


class Bullet : SKSpriteNode {
    
    //new
    
    var player: Tank!
    var isLocal: Bool!
    var global: GamePlayScene!
    
    init(position: CGPoint, angle: CGFloat, player: Tank, global: GamePlayScene,isLocal: Bool){
        super.init(texture: SKTexture(imageNamed: "bullet"), color: UIColor.clear, size: CGSize(width: 20, height: 40))
        self.position = position
        self.zRotation = angle
        let angle = angle + .pi/2
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.velocity = CGVector(dx: 500*cos(angle), dy: 500*sin(angle))
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = shotCat
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = playerCat | obstacleCat
        self.physicsBody!.isDynamic = true
        self.physicsBody!.usesPreciseCollisionDetection = true
   
        
        self.player = player
        self.isLocal = isLocal
        
        self.global = global
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func die(){
        self.removeFromParent()
    }
}


