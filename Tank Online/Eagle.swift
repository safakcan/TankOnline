//
//  Eagle.swift
//  Tank Online
//
//  Created by Can Bas on 2.01.2018.
//  Copyright © 2018 Can Bas. All rights reserved.
//
import SpriteKit

class Eagle : SKSpriteNode {
    
    var global: GamePlayScene!
    var type: Int!
    var body = SKSpriteNode()
    var blockSize : Int = 50
    
    init(position: CGPoint, global: GamePlayScene, type: Int){
        super.init(texture: SKTexture(imageNamed: "eagle"), color: UIColor.clear, size: CGSize(width: blockSize*2, height: blockSize))
        self.colorBlendFactor = 1
        
        self.global = global
        if(type == 1){
            body = SKSpriteNode(texture: SKTexture(imageNamed: "eagle"), color: UIColor.clear, size: CGSize(width: blockSize*2, height: blockSize))
            body.name = "eagle"
        }else{
            body = SKSpriteNode(texture: SKTexture(imageNamed: "damagedEagle"), color: UIColor.clear, size: CGSize(width: blockSize*2, height: blockSize))
            body.name = "damagedEagle"
        }
        body.position = position
        body.zPosition = 2
        body.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        body.physicsBody!.isDynamic = false
        body.physicsBody!.categoryBitMask = obstacleCat
        
        global.addChild(body)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

