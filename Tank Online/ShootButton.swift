import SpriteKit
import GameplayKit
import Darwin
import Foundation

class ShootButton: SKSpriteNode {
    
    var button = SKSpriteNode()
    var global: GamePlayScene!
    let constantSize: CGFloat = 50
    
    init(global: GamePlayScene) {
        
        //Init Self
        super.init(texture: SKTexture(imageNamed: "fireButton"), color: UIColor.gray, size: CGSize(width: constantSize, height: constantSize))
        print(global.frame.maxX)
        print(global.frame.maxY)
        self.position = CGPoint(x: global.frame.maxX - self.size.width, y: global.frame.minY + self.size.height)
        self.zPosition = 2 
        //others
        self.global = global
        
        isUserInteractionEnabled = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateButton(pos: CGPoint){
        let angle = global.players[global.currentPlayerIndex].zRotation
        global.players[global.currentPlayerIndex].changeTurret(angle: angle, isOn: true, send: true)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else {
            return;}
        let pos = touch.location(in: self)
        updateButton(pos: pos)
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
}

