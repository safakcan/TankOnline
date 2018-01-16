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
    var gameScene: GamePlayScene = GamePlayScene(fileNamed : "GameScene")!
    var mainScene: MainMenuScene = MainMenuScene(fileNamed: "MainMenu")!
    
    static var gameType : String = ""
    
    @IBAction func startButtonClicked() {
        GameViewController.gameType = "single"
    }
    
    @IBAction func startMultiplayerClicked(){
        GameViewController.gameType = "multi"
        GameKitHelper.sharedGameKitHelper.authenticateLocalPlayer()
        if (isAuthenticated){
            GameKitHelper.sharedGameKitHelper.findMatchWithMinPlayers(minPlayers: 2, maxPlayers: 2, viewController: self, delegate: networkingEngine!)
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        GameViewController.gameType = "info"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerAuthenticated), name: NSNotification.Name(rawValue: LocalPlayerIsAuthenticated), object: nil)
           // loadMenuScene()
        if(GameViewController.gameType == "single"){
            if let view = self.view as! SKView? {
                // Set the scale mode to scale to fit the window
                gameScene.isMultiplayer = false
                gameScene.scaleMode = .fill
                gameScene.viewController = self
                gameScene.networkingEngine = networkingEngine
                // Present the scene
                view.presentScene(gameScene)
            }
            gameScene.currentPlayerIndex = 0
        }else if(GameViewController.gameType == "multi"){
            if let view = self.view as! SKView? {
                // Set the scale mode to scale to fit the window
                gameScene.isMultiplayer = true
                gameScene.scaleMode = .fill
                gameScene.viewController = self
                gameScene.networkingEngine = networkingEngine
                // Present the scene
                view.presentScene(gameScene)
            }
            gameScene.currentPlayerIndex = 0
        }else if(GameViewController.gameType == "info"){
            
        }
    }
    
    func playerAuthenticated() {
        
        networkingEngine = MultiplayerNetworking()
        mainScene = MainMenuScene(size: view.bounds.size)
        gameScene = GamePlayScene(size: view.bounds.size)
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
    
//    func loadMenuScene() {
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//                mainScene.scaleMode = .aspectFill
//
//                // Present the scene
//                view.presentScene(mainScene)
//        }
//
//    }
    
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
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
