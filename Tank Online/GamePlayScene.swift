//
//  GamePlayScene.swift
//  Tank Online
//
//  Created by Can Bas on 3/3/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import SpriteKit
import GameplayKit
import Darwin
import Foundation

var allCategory: UInt32 = 0xFFFFFFFF
var playerCat: UInt32 = 1 << 1 //2
var obstacleCat: UInt32 = 1 << 2 //4?
var shotCat: UInt32 = 1 << 3 //8

class GamePlayScene : SKScene, SKPhysicsContactDelegate, MultiplayerNetworkingProtocol{

    var viewController: GameViewController!
    var lastTime = NSDate()
    
    var networkingEngine: MultiplayerNetworking?
    
    var players = Array<Tank>()
    var walls = Array<Wall>()
    var bots = Array<Bot>()
    var currentPlayerIndex: Int = 0
    var scores = Array<Int>()
    var scoreBar : SKLabelNode!
    var enemyScoreBar : SKLabelNode!
    
    var isBotAdded : Bool = false
    var isGameFinished: Bool = false
    var isMultiplayer : Bool = false

    var kartal1 : SKSpriteNode = SKSpriteNode()
    var kartal2 : SKSpriteNode = SKSpriteNode()
   
    var blockSize = CGFloat()
    var grid : Grid?;
    
    override func didMove(to view: SKView) {
    
        self.removeAllChildren()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect( x: 0, y: 0, width: self.size.width, height: self.size.height))
        physicsWorld.contactDelegate = self
        isUserInteractionEnabled = true
    
        scoreBar = SKLabelNode(fontNamed: "Chalkduster")
        scoreBar.text = "Score: 0"
        scoreBar.position = CGPoint(x: frame.midX+150, y: frame.minY)
        scoreBar.color = SKColor.white
        scoreBar.fontSize = 10
        scoreBar.zPosition = 3
        self.addChild(scoreBar)
        
        if(isMultiplayer){
            enemyScoreBar = SKLabelNode(fontNamed: "Chalkduster")
            enemyScoreBar.text = "Score: 0"
            enemyScoreBar.position = CGPoint(x: frame.midX+150, y: frame.maxY-10)
            enemyScoreBar.color = SKColor.white
            enemyScoreBar.fontSize = 10
            enemyScoreBar.zPosition = 3
            self.addChild(enemyScoreBar)
        }
        self.addChild(ShootButton(global: self))
        blockSize = 50
        if let grid = Grid(blockSize: blockSize, rows: Int((self.frame.height)/blockSize) , cols: Int((self.frame.width)/blockSize)) {
            grid.name = "grid"
            grid.anchorPoint = self.anchorPoint
            grid.position = self.position
            grid.zPosition = 1
            self.addChild(grid)
            initializePlayer(grid: grid);
            initializeWall(grid: grid);
            self.setGrid(grid: grid)
            var eagle = Eagle(position: grid.gridPosition(row: Int((self.frame.height)/blockSize)-1, col: Int((self.frame.width)/blockSize)/2), global: self , type: 1)
            eagle.name = "eagle"
        }
        self.setGrid(grid: grid!)
        
    }
    
    func addBot()
    {
        if(!isGameFinished){
            let row = Int(arc4random_uniform(7))
            let col = Int(arc4random_uniform(13))
            var bot = Bot(position: (self.grid?.gridPosition(row: row , col: col))!, global : self)
            if(isNodeEmpty(location: bot.position)){
                self.addChild(bot)
                bots.append(bot)
            }else{
                addBot()
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        networkingEngine?.sendMove(player: players[currentPlayerIndex])
        if(!isBotAdded){
            DispatchQueue.global(qos : .userInitiated).async {
                DispatchQueue.main.async {
                    var helloWorldTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.addBot), userInfo: nil, repeats: true)
                }
            }
            if(!isGameFinished){
                isBotAdded = true;
            }
        }
        moveBots(position: players[currentPlayerIndex].position)
    }
    
    func moveBots( position : CGPoint){
        for b in bots{
            var reflectPoint = CGPoint(x: 2 * self.anchorPoint.x - players[currentPlayerIndex].position.x, y: 2 * self.anchorPoint.y - players[currentPlayerIndex].position.y)
            b.movePlayerToLocation(location: getPositionOfLocation(location : reflectPoint ))
        }
    }
    
    private func initializePlayer(grid : Grid){
        var newPlayer = Tank(index: 0, pos:  grid.gridPosition(row: 3, col: 5), angle: 0, global: self)
        newPlayer.name = "0"
        players.append(newPlayer)
        scores.append(0)
        if(isMultiplayer){
            newPlayer = Tank(index: 1, pos: grid.gridPosition(row: 0, col: 5), angle: 0, global: self)
            newPlayer.name = "tank"
            players.append(newPlayer)
            scores.append(0)
        }
    }
    
    private func initializeWall(grid : Grid){
        for i in 1 ... 8{
            var wall = Wall(position: grid.gridPosition(row: i , col: 4 ), global : self)
            wall.zPosition = 2
            wall.name = "wall\(i)"
            walls.append(wall)
        }
        
    }
    
    func didBegin(_ contact : SKPhysicsContact){ //carpisan objeleri yok etmeye yariyor bodyler artirilarak yok edilmek istenen seyler de artirilabilir
        
        let bodyA =  contact.bodyA.node?.name
        let bodyB =  contact.bodyB.node?.name
        
        if(bodyA == nil || bodyB == nil){
            return
        }
        
        if ((bodyA?.contains("bullet"))! && (bodyB?.contains("wall"))!){
            contact.bodyA.node?.isHidden = true
            contact.bodyA.node?.physicsBody?.pinned = true
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
        }else if((bodyA?.contains("wall"))! && (bodyB?.contains("bullet"))!){
            contact.bodyB.node?.isHidden = true
            contact.bodyB.node?.physicsBody?.pinned = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }else if ((bodyA?.contains("bullet"))! && (bodyB?.contains("tank"))!){
            contact.bodyA.node?.isHidden = true
            contact.bodyA.node?.physicsBody?.pinned = true
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
            self.changePoint(index: currentPlayerIndex, amount: 500)
        }else if((bodyA?.contains("tank"))! && (bodyB?.contains("bullet"))!){
            contact.bodyB.node?.isHidden = true
            contact.bodyB.node?.physicsBody?.pinned = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            self.changePoint(index: currentPlayerIndex, amount: 500)
        }else if ((bodyA?.contains("bullet"))! && (bodyB?.contains("bot"))!){
            contact.bodyA.node?.isHidden = true
            contact.bodyA.node?.physicsBody?.pinned = true
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
     //       bots.remove(at: bots.index(of: contact.bodyB.node as! Bot)!)
            self.changePoint(index: currentPlayerIndex, amount: 100)
        }else if((bodyA?.contains("bot"))! && (bodyB?.contains("bullet"))!){
            contact.bodyB.node?.isHidden = true
            contact.bodyB.node?.physicsBody?.pinned = true
      //      bots.remove(at: bots.index(of: contact.bodyA.node as! Bot)!)
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            self.changePoint(index: currentPlayerIndex, amount: 100)
        }else if((bodyA?.contains("bullet"))! && (bodyB?.contains("eagle"))!){
            contact.bodyA.node?.isHidden = true
            contact.bodyA.node?.physicsBody?.pinned = true
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
            var eagle = Eagle(position: (grid?.gridPosition(row: Int((self.frame.height)/blockSize)-1, col: Int((self.frame.width)/blockSize)/2))!, global: self , type: 2)
            eagle.size = CGSize(width: eagle.size.width-3, height:eagle.size.height-3)
            eagle.name = "damagedEagle"
            self.addChild(eagle)
            self.changePoint(index: currentPlayerIndex, amount: 100)
        }else if((bodyA?.contains("eagle"))! && (bodyB?.contains("bullet"))!){
            contact.bodyB.node?.isHidden = true
            contact.bodyB.node?.physicsBody?.pinned = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            var eagle = Eagle(position: (grid?.gridPosition(row: Int((self.frame.height)/blockSize)-1, col: Int((self.frame.width)/blockSize)/2))!, global: self , type: 2)
            eagle.size = CGSize(width: eagle.size.width-3, height:eagle.size.height-3)
            eagle.name = "damagedEagle"
            self.addChild(eagle)
            self.changePoint(index: currentPlayerIndex, amount: 100)
        }else if((bodyA?.contains("bullet"))! && (bodyB?.contains("damagedEagle"))!){
            contact.bodyA.node?.isHidden = true
            contact.bodyA.node?.physicsBody?.pinned = true
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
            print("GAME OVER")
            self.changePoint(index: currentPlayerIndex, amount: 500)
            isGameFinished = true
            isBotAdded = true
            self.removeAllChildren()
            let winner = SKLabelNode(fontNamed: "Chalkduster")
            winner.text = "Game Over"
            winner.fontSize = 65
            winner.fontColor = SKColor.black
            winner.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(winner)
        }else if((bodyA?.contains("damagedEagle"))! && (bodyB?.contains("bullet"))!){
            contact.bodyB.node?.isHidden = true
            contact.bodyB.node?.physicsBody?.pinned = true
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            print("GAME OVER")
            self.changePoint(index: currentPlayerIndex, amount: 500)
            scoreBar.text = "Score : \(scores[currentPlayerIndex])"
            isGameFinished = true
            isBotAdded = true
            self.removeAllChildren()
            let winner = SKLabelNode(fontNamed: "Chalkduster")
            winner.text = "Game Over"
            winner.fontSize = 65
            winner.fontColor = SKColor.black
            winner.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(winner)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let location = touch.location(in: self)
            let touchNode = self.nodes(at: location)
            if(touchNode.first?.name == "grid"){
                players[currentPlayerIndex].movePlayerToLocation(location: getPositionOfLocation(location: location))
            }
            }
        }
    
    func isNodeEmpty(location : CGPoint) -> Bool{
        let selectedNode = self.nodes(at: location)
        if(selectedNode.first?.name == "grid"){
            return true
        }
        return false
    }
    
    func getPositionOfLocation(location : CGPoint) -> CGPoint{
        var x = 0
        var y = 0
        if(location.x <= 0){
            x = Int(location.x) - (Int(location.x) % 50) - 25
        }else{
            x = Int(location.x) - (Int(location.x) % 50) + 25
        }
        if(location.y <= 0){
            y = Int(location.y) - (Int(location.y) % 50) - 25
        }else{
            y = Int(location.y) - (Int(location.y) % 50) + 25
        }
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    func getGrid() -> Grid {
        return grid!
    }

    func setGrid(grid: Grid){
        self.grid = grid;
    }
    
    func matchEnded(scores: Array<Int>) {
        if (scores[currentPlayerIndex] == 1){
            self.backgroundColor = SKColor.green
        }
        else{
            self.backgroundColor = SKColor.red
        }
    }
    
    func setCurrentPlayerIndex(index: Int) {
         currentPlayerIndex = index
    }
    
    func movePlayer(index: Int, position: CGPoint) {
        players[index].recievedMove(position: position)
    }
    
    func changeTurret(index: Int, angle: CGFloat, isOn: Bool){
        if(currentPlayerIndex != -1){
            players[index].changeTurret(angle: angle, isOn: isOn, send: false)
        }
    }
    func shoot(index: Int, position: CGPoint, angle: CGFloat, type: Int){
        if(currentPlayerIndex != -1){
            players[index].shoot(position: position, angle: angle, send: false)
        }
    }
    
    func changePoint(index: Int, amount: Int) {
        if(index == currentPlayerIndex && isMultiplayer){
            networkingEngine?.sendPoint(amount: amount)
        }
        scores[currentPlayerIndex] += amount
        scoreBar.text = "Score : \(scores[currentPlayerIndex])"
    }

}


