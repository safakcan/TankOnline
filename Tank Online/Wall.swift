//
//  Wall.swift
//  Tank Online
//
//  Created by Can Bas on 3/18/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import SpriteKit

class Wall : SKSpriteNode {

    var global: GamePlayScene!
    var type: Int!
    var body = SKSpriteNode()
    var blockSize : Int = 50
    
    init(position: CGPoint, global: GamePlayScene){
        super.init(texture: SKTexture(imageNamed: "wall 2"), color: UIColor.clear, size: CGSize(width: blockSize, height: blockSize))
        self.colorBlendFactor = 1
        
        self.global = global
        
        body = SKSpriteNode(texture: SKTexture(imageNamed: "wall 2"), color: UIColor.clear, size: CGSize(width: blockSize, height: blockSize))
        body.position = position
        body.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        body.physicsBody!.isDynamic = false
        body.physicsBody!.categoryBitMask = obstacleCat
        body.name = "wall"
        global.addChild(body)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
