//
//  Wall.swift
//  Tank Online
//
//  Created by Can Bas on 3/18/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import SpriteKit
import GameplayKit

class Bot : SKSpriteNode {
    
    var global: GamePlayScene!
    var type: Int!
    var body = SKSpriteNode()
    var blockSize : Int = 50
    
    init(position: CGPoint, global: GamePlayScene){
        super.init(texture: SKTexture(imageNamed: "bot"), color: UIColor.clear, size: CGSize(width: blockSize, height: blockSize))
        self.colorBlendFactor = 1
        
        self.global = global
        
        body = SKSpriteNode(texture: SKTexture(imageNamed: "bot"), color: UIColor.clear, size: CGSize(width: blockSize, height: blockSize))
        body.position = position
        body.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        body.physicsBody!.isDynamic = true
        body.physicsBody!.categoryBitMask = playerCat
        body.physicsBody!.contactTestBitMask = shotCat
        body.physicsBody!.collisionBitMask = obstacleCat
        body.physicsBody!.usesPreciseCollisionDetection = true
        body.physicsBody!.affectedByGravity = false
        body.physicsBody!.linearDamping = 0
        body.physicsBody!.angularDamping = 0
        
        body.name = "bot"
        global.addChild(body)
//        DispatchQueue.global(qos : .userInitiated).async {
//            DispatchQueue.main.async {
//                self.randomlyMove()
//            }
//        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func randomlyMove(){
        let goA  = SKAction.run{
            let row = Int(arc4random_uniform(10))
            let col = Int(arc4random_uniform(10))
            self.movePlayerToLocation(location: (self.global.grid!.gridPosition(row: row, col: col)))
        }
        let wait = SKAction.wait(forDuration: 2)
        let sequence = SKAction.sequence([goA, wait])
        self.run(sequence)
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
        let graph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 10)
        
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
    }
    func turn (left: CGFloat , down : CGFloat, i : Int) -> SKAction{
        if (down < self.position.y && i == 1){
            return SKAction.rotate(toAngle: CGFloat(Double.pi), duration: 0.2)
        }
        if (down > self.position.y && i == 1){
            return SKAction.rotate(toAngle: CGFloat(Double.pi)*2, duration: 0.2)
        }
        if (left < self.position.x && i == 2){
            return SKAction.rotate(toAngle: CGFloat(Double.pi/2), duration: 0.2)
        }
        if (left > self.position.x && i == 2){
            return SKAction.rotate(toAngle: CGFloat(-Double.pi/2), duration: 0.2)
        }
        return SKAction.fadeIn(withDuration: 0.5)
    }
}

