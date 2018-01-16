//
//  Tank.swift
//  Tank Online
//
//  Created by Can Bas on 3/18/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import SpriteKit
import GameplayKit


class Tank : SKSpriteNode {
    
    var global: GamePlayScene!
    var turret: SKSpriteNode!
    var score: Int = 0
    var index: Int = -1
    var scoreBar: SKLabelNode = SKLabelNode(fontNamed: "Score : 0 ")
    var blocksize : Int = 50
    
    init(index: Int, pos: CGPoint, angle: CGFloat, global: GamePlayScene) {
        
        //Init Self
        super.init(texture: SKTexture(imageNamed: "tank"), color: UIColor.clear, size: CGSize(width: blocksize, height: blocksize))
        self.position = pos
        self.zPosition = 2
        self.zRotation = angle
        self.index = index
        
        //Init Body
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody?.categoryBitMask = playerCat
        self.physicsBody?.contactTestBitMask = shotCat
        self.physicsBody?.collisionBitMask = obstacleCat
        
        self.global = global
        isUserInteractionEnabled = false
        
//        //The rocket emitter in back for animation purposes
//        rocket = SKEmitterNode(fileNamed: "Rocket.sks")
//        rocket.position = CGPoint(x: 0, y: -20)
//        rocket.zRotation = .pi
//        rocket.setScale(0.5)
//        addChild(rocket)
//        changeRocket(isOn: false, send: false)
        
        //Turret
        turret = SKSpriteNode()
        turret.size = CGSize(width: 25, height: 25)
        turret.zPosition = 10
        self.addChild(turret)
        
        global.addChild(self)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func changeTurret(angle: CGFloat, isOn: Bool, send: Bool){
        if(send && global.isMultiplayer){global.networkingEngine?.sendTurret(angle: angle, isOn: isOn)}
        self.shoot(position: self.position, angle: angle, send: true)
    }
    func shoot(position: CGPoint, angle: CGFloat, send: Bool){
        if(send && global.isMultiplayer){global.networkingEngine?.sendShoot(position: position, angle: angle, type: 1)}
        let shot = Bullet(position: position, angle: angle,  player: self, global: global, isLocal: send)
        shot.name = "bullet"
        global.addChild(shot)
    }
//    func changeRocket(isOn: Bool, send: Bool){
//        if(send){global.networkingEngine?.sendRocket(isOn: isOn)}
//        if(isOn){
//            rocket.numParticlesToEmit = -1
//        } else{
//            rocket.numParticlesToEmit = 1
//        }
//    }
    func updatePlayer(angle: CGFloat, length: CGFloat, maxLength: CGFloat, posX: CGFloat){
        zRotation = angle - .pi/2
//        var force = CGVector(dx: length*cos(angle)*power/maxLength, dy: length*sin(angle)*power/maxLength)
//        if(posX < 0){
//            force.dx *= -1
//            force.dy *= -1
//            zRotation -= .pi
//        }
//        currentForce = force
    }
    
    func recievedMove(position: CGPoint){
      movePlayerToLocation(location: position)
    }
    
    var moving : Bool = false
    
    func movePlayerToLocation(location: CGPoint) {
        
        // Ensure the player doesn't move when they are already moving.
        guard (!moving) else {return}
        moving = true
        
        // Create an array of obstacles, which is every child node, apart from the player node.
        let obstacles = SKNode.obstacles(fromNodeBounds: global.children.filter({ (element ) -> Bool in
            if(element == self || element.name == "grid" || element.name == "cam"){
                return false
            }
            return true
        }))
        
        
        // Assemble a graph based on the obstacles. Provide a buffer radius so there is a bit of space between the
        // center of the player node and the edges of the obstacles.
        let graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 5)
        
        // Create a node for the user's current position, and the user's destination.
        let startNode = GKGraphNode2D(point: float2(Float(self.position.x), Float(self.position.y)))
        let endNode = GKGraphNode2D(point: float2(Float(location.x), Float(location.y)))
        
        // Connect the two nodes just created to graph.
        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)
        
        // Find a path from the start node to the end node using the graph.
        let path:[GKGraphNode] = graph.findPath(from: startNode, to: endNode)
        
        // If the path has 0 nodes, then a path could not be found, so return.
        guard path.count > 0 else { moving = false; return }
        
        
        // Create an array of actions that the player node can use to follow the path.
        var actions = [SKAction]()
        var oncekix = self.position.x
        var oncekiy = self.position.y
        
        for node:GKGraphNode in path {
            if let point2d = node as? GKGraphNode2D {
                if(oncekix != CGFloat(point2d.position.x)){
                let point = CGPoint(x: CGFloat(point2d.position.x), y: oncekiy)
                let action = SKAction.move(to: point, duration: TimeInterval(abs((point.x - oncekix) / 300)))
                actions.append(turn(left: point.x,down: point.y, i: 2))
                actions.append(action)
                }
                if(oncekiy != CGFloat(point2d.position.y)){
                let point2 = CGPoint(x: CGFloat(point2d.position.x), y: CGFloat(point2d.position.y))
                let action2 = SKAction.move(to: point2, duration: TimeInterval(abs((point2.y - oncekiy) / 300)))
                actions.append(turn(left: point2.x,down: point2.y, i: 1))
                actions.append(action2)
                }
                oncekiy = CGFloat(point2d.position.y)
                oncekix = CGFloat(point2d.position.x)
            }
        }
        
        // Convert those actions into a sequence action, then run it on the player node.
        let sequence = SKAction.sequence(actions)
        self.run(sequence, completion: { () -> Void in
            self.moving = false
        })
        if(global.isMultiplayer){
            global.networkingEngine?.sendMove(player: self)
        }
    }
    
    func turn (left: CGFloat , down : CGFloat, i : Int) -> SKAction{
        if (down < self.position.y && i == 1){
            return SKAction.rotate(toAngle: CGFloat(M_PI), duration: 0.2)
        }
        if (down > self.position.y && i == 1){
            return SKAction.rotate(toAngle: CGFloat(M_PI)*2, duration: 0.2)
        }
        if (left < self.position.x && i == 2){
            return SKAction.rotate(toAngle: CGFloat(M_PI_2), duration: 0.2)
        }
        if (left > self.position.x && i == 2){
            return SKAction.rotate(toAngle: CGFloat(-M_PI_2), duration: 0.2)
        }
        return SKAction.fadeIn(withDuration: 1)
    }
}
