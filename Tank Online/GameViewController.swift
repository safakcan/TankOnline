//
//  GameViewController.swift
//  Tank Online
//
//  Created by Can Bas on 3/3/17.
//  Copyright © 2017 Can Bas. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {

    var networkingEngine: MultiplayerNetworking?
    var isAuthenticated: Bool = false
    var gameScene: GamePlayScene = GamePlayScene()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    static var gameType : String = ""
    

    @IBAction func startButtonClicked(_ sender: UIButton) {
        hideButtons()
        GameViewController.gameType = "single"
        loadGameScene()
    }
    
    @IBAction func startMultiplayerClicked(_ sender: UIButton) {
        hideButtons()
        GameViewController.gameType = "multi"
        GameKitHelper.sharedGameKitHelper.authenticateLocalPlayer()
        if (isAuthenticated){
            GameKitHelper.sharedGameKitHelper.findMatchWithMinPlayers(minPlayers: 2, maxPlayers: 2, viewController: self, delegate: networkingEngine!)
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        hideButtons()
        GameViewController.gameType = "info"
    }
    
    func hideButtons(){
         startButton.isHidden = true
         multiButton.isHidden = true
         infoButton.isHidden = true
        startButton.isEnabled = false
        multiButton.isEnabled = false
        infoButton.isEnabled = false
    }
    
    func showButtons(){
        startButton.isHidden = false
        multiButton.isHidden = false
        infoButton.isHidden = false
        startButton.isEnabled = true
        multiButton.isEnabled = true
        infoButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerAuthenticated), name: NSNotification.Name(rawValue: LocalPlayerIsAuthenticated), object: nil)
       
    }
    
    func loadGameScene(){
        
        if(GameViewController.gameType == "single"){
            if let view = view as! SKView? {
                // Set the scale mode to scale to fit the window
                gameScene.isMultiplayer = false
                gameScene.scaleMode = .resizeFill
                gameScene.viewController = self
                gameScene.networkingEngine = networkingEngine
                // Present the scene
                view.ignoresSiblingOrder = true
                view.presentScene(gameScene)
            }
            gameScene.currentPlayerIndex = 0
        }else if(GameViewController.gameType == "multi"){
            if let view = view as! SKView? {
                // Set the scale mode to scale to fit the window
                gameScene.isMultiplayer = true
                gameScene.scaleMode = .resizeFill
                gameScene.viewController = self
                gameScene.networkingEngine = networkingEngine
                // Present the scene
                view.ignoresSiblingOrder = true
                view.presentScene(gameScene)
            }
            gameScene.currentPlayerIndex = 0
        }else if(GameViewController.gameType == "info"){
            
        }
    }
    
    func playerAuthenticated() {
        
        networkingEngine = MultiplayerNetworking()
        networkingEngine!.delegate = gameScene
        networkingEngine!.viewController = self
        
        isAuthenticated = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func matchStarted() {
        print("Match started")
    }
    
    func matchEnded() {
        print("Match ended")
    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String) {
        print("Received data")
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
