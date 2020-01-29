//
//  GameOverScene.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/15/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene, SKPhysicsContactDelegate {
    
    var score : Int = 0
    
    var scoreLabel : SKLabelNode!
    var highScoreLabel : SKLabelNode!
    var highScoreIndicator : SKLabelNode!
    var continueLabel : SKLabelNode!
    var coinLabel : SKLabelNode!
    var coinImage : SKSpriteNode!
    var newGameButton : SKSpriteNode!
    
    var scoreEffect : SKEmitterNode!
    
    var coins : Int = UserDefaults.standard.integer(forKey: "coins")
    
//    Play count
    var playCount = Int()
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        scene?.scaleMode = SKSceneScaleMode.aspectFit
        
        let fontName = "VCR OSD Mono"
        
//        Update play count
        playCount = UserDefaults.standard.integer(forKey: "playCount")
        
//        Create score label
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = 200
        scoreLabel.fontColor = UIColor.white
        scoreLabel.alpha = 1.0
        scoreLabel.position = CGPoint(x: 0, y: 0 + (self.size.height / 6))
        scoreLabel.physicsBody?.isDynamic = false
        self.addChild(scoreLabel)
        scoreLabel.text = "\(score)"
        
//        Create high score label
        highScoreLabel = SKLabelNode(fontNamed: fontName)
        highScoreLabel.fontSize = 200
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.alpha = 1.0
        highScoreLabel.position = CGPoint(x: 0, y: 0)
        highScoreLabel.physicsBody?.isDynamic = false
        self.addChild(highScoreLabel)
        highScoreLabel.text = "High Score: \(score)" // dont worry we update it down below, it just has to be done last
        
//        Create high score indicator
        highScoreIndicator = SKLabelNode(fontNamed: fontName)
        highScoreIndicator.fontSize = 200
        highScoreIndicator.fontColor = UIColor.white
        highScoreIndicator.alpha = 0.0
        highScoreIndicator.position = CGPoint(x: 0, y: 0)
        highScoreIndicator.physicsBody?.isDynamic = false
        self.addChild(highScoreIndicator)
        highScoreIndicator.text = "HIGH SCORE!"
        
//        Create coin image & label
        coinImage = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "coin")), size: CGSize(width: self.size.width / 16, height: self.size.width / 16))
        coinImage.position = CGPoint(x: 0, y: 0)
        coinImage.physicsBody?.affectedByGravity = false
        coinImage.physicsBody?.isDynamic = false
        coinImage.zPosition = -1
        coinImage.alpha = 1.0
        self.addChild(coinImage)
        
        coinLabel = SKLabelNode(fontNamed: fontName)
        coinLabel.fontSize = 100
        coinLabel.fontColor = UIColor.white
        coinLabel.zPosition = 0
        coinLabel.alpha = 1.0
        coinLabel.physicsBody?.isDynamic = false
        coinLabel.horizontalAlignmentMode = .center
        coinLabel.position = CGPoint(x: 0, y: 0)
        self.addChild(coinLabel)
        self.coinLabel.text = "\(coins)" // same here, we update it down below
        
//        Create blinking 'Tap to continue' label
        continueLabel = SKLabelNode(fontNamed: fontName)
        continueLabel.fontSize = 200
        continueLabel.fontColor = UIColor.white
        continueLabel.alpha = 1.0
        continueLabel.physicsBody?.isDynamic = false
        
        var blinkingContinueLabelArray = [SKAction]()
        
        blinkingContinueLabelArray.append(SKAction.fadeAlpha(to: 0.0, duration: 1.0))
        blinkingContinueLabelArray.append(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
        blinkingContinueLabelArray.append(SKAction.wait(forDuration: 1.5))
        
        continueLabel.run(SKAction.repeatForever(SKAction.sequence(blinkingContinueLabelArray)))
        
        continueLabel.position = CGPoint(x: 0, y: 0 - (self.size.height / 5))
        self.addChild(continueLabel)
        continueLabel.text = "Tap to continue"
        
//        Create new game button
        let newGameButtonColor = UIColor.white
        let newGameButtonSize = CGSize(width: self.size.width, height: self.size.height)
        
        newGameButton = SKSpriteNode(color: newGameButtonColor, size: newGameButtonSize)
        newGameButton.physicsBody?.affectedByGravity = false
        newGameButton.physicsBody?.isDynamic = false
        newGameButton.physicsBody?.pinned = true
        newGameButton.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        newGameButton.position = CGPoint(x: 0, y: 0)
        newGameButton.zPosition = 1
        newGameButton.alpha = 0.01
        self.addChild(newGameButton)
        newGameButton.name = "newGameButton"
        
//        Create border around screen
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        
//        Sizing constraints
        while scoreLabel.frame.height < self.frame.height * 0.12 {
            scoreLabel.fontSize += 5
        }
        while scoreLabel.frame.height > self.frame.height * 0.12 {
            scoreLabel.fontSize -= 5
        }
        while scoreLabel.frame.width > self.frame.width * 0.75 {
            scoreLabel.fontSize -= 5
        }
        
        while highScoreLabel.frame.width < self.frame.width * 0.6 {
            highScoreLabel.fontSize += 5
        }
        while highScoreLabel.frame.width > self.frame.width * 0.6 {
            highScoreLabel.fontSize -= 5
        }
        
        while highScoreIndicator.frame.width < self.frame.width {
            highScoreIndicator.fontSize += 5
        }
        while highScoreIndicator.frame.width > self.frame.width {
            highScoreIndicator.fontSize -= 5
        }
        
        while continueLabel.frame.width < self.frame.width * 0.8 {
            continueLabel.fontSize += 5
        }
        while continueLabel.frame.width > self.frame.width * 0.8 {
            continueLabel.fontSize -= 5
        }
        
        while coinLabel.frame.height < coinImage.size.height * 0.8 {
            coinLabel.fontSize += 5
        }
        while coinLabel.frame.height > coinImage.size.height * 0.8 {
            coinLabel.fontSize -= 5
        }
        
//        Check whether high score was updated (from the Bool "highScoreUpdated" we save in UserDefaults) last round and display an skemitternode depending on if it was updated (whether it was a high score or not)
        if UserDefaults.standard.bool(forKey: "highScoreUpdated") == true {
            highScoreIndicator.alpha = 1.0
            
            scoreEffect = SKEmitterNode(fileNamed: "endscreenhighscore")!
            scoreEffect.position = CGPoint(x: 0, y: 0 + (self.frame.height / 2))
            self.addChild(scoreEffect)
        } else {
            scoreEffect = SKEmitterNode(fileNamed: "endscreennormal")!
            scoreEffect.position = CGPoint(x: 0, y: 0 + (self.frame.height / 2))
            self.addChild(scoreEffect)
        }
        
        checkPlayCountAndDisplay()
        
//        ADD MINI PLAYERS (if ad is not on screen)
        addMiniPlayers(quantity: score)
        
//        things that need to be updated/done last
        highScoreLabel.text = "High Score: \(UserDefaults.standard.integer(forKey: "highScore"))"
        highScoreIndicator.position = CGPoint(x: 0, y: (0 + ((self.frame.height / 2) - highScoreIndicator.frame.height)) - (self.frame.height * 0.05))
        highScoreLabel.position = CGPoint(x: 0, y: scoreLabel.position.y - highScoreLabel.frame.height)
        while (highScoreIndicator.position.y + highScoreIndicator.frame.height) > self.frame.height {
            highScoreIndicator.position.y -= 1
        }
        
        coins = UserDefaults.standard.integer(forKey: "coins")
        coinLabel.text = "\(coins)"
        
        coinLabel.position = CGPoint(x: 0 + (coinLabel.frame.size.width * 0.4), y: highScoreLabel.position.y - (highScoreLabel.frame.height / 2) - (coinImage.size.height * 0.8))
        coinImage.position = CGPoint(x: coinLabel.position.x - (coinLabel.frame.size.width * 0.85), y: coinLabel.position.y + (coinImage.size.height * 0.4))
    }
    
//    Ad functions
    func displayAd() {
        NotificationCenter.default.post(name: NSNotification.Name("loadAndShowInterstitial"), object: nil)
    }
    
    func checkPlayCountAndDisplay() {
        if playCount % 2 == 0 {
            if UserDefaults.standard.bool(forKey: "removeAdsPurchased") == false {
                displayAd()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton" {
                let transition = SKTransition.fade(withDuration: 2)
                let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
                gameScene.scaleMode = .aspectFill
                
                removeAllChildren()
                
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    func addMiniPlayers(quantity: Int) {
        var miniPlayerAmount: Int = 0
        
        if score > 250 {
            if score == 420 {
                while miniPlayerAmount < 250 {
                    // these were my 'finishing touches' :^)
                    let miniPlayer = SKSpriteNode(imageNamed: "weed")
                    miniPlayer.size = CGSize(width: self.size.width / 12, height: self.size.height / 12)
                    
                    let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (miniPlayer.size.width / 2))), highestValue: Int((self.size.width / 2) - (miniPlayer.size.width / 2)))
                    let positionX = CGFloat(randomXPosition.nextInt())
                    let randomYPosition = GKRandomDistribution(lowestValue: Int(self.size.height / 6), highestValue: Int(self.size.height / 2))
                    let positionY = CGFloat(randomYPosition.nextInt())
                    
                    miniPlayer.position = CGPoint(x: positionX, y: positionY)
                    miniPlayer.physicsBody = SKPhysicsBody(circleOfRadius: max(miniPlayer.size.width * 0.4, miniPlayer.size.width * 0.4))
                    miniPlayer.physicsBody?.isDynamic = true
                    miniPlayer.physicsBody?.affectedByGravity = true
                    miniPlayer.physicsBody?.mass = 0
                    miniPlayer.physicsBody?.friction = 0
                    miniPlayer.physicsBody?.restitution = 1
                    self.addChild(miniPlayer)
                    miniPlayerAmount += 1
                }
            } else if score != 420 {
                while miniPlayerAmount < 250 {
                    let miniPlayer = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: "playerTexture")!)
                    miniPlayer.size = CGSize(width: self.size.width / 12, height: self.size.width / 6)
                    
                    let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (miniPlayer.size.width / 2))), highestValue: Int((self.size.width / 2) - (miniPlayer.size.width / 2)))
                    let positionX = CGFloat(randomXPosition.nextInt())
                    let randomYPosition = GKRandomDistribution(lowestValue: Int(self.size.height / 6), highestValue: Int(self.size.height / 2))
                    let positionY = CGFloat(randomYPosition.nextInt())
                    
                    miniPlayer.position = CGPoint(x: positionX, y: positionY)
                    miniPlayer.physicsBody = SKPhysicsBody(circleOfRadius: max(miniPlayer.size.width * 0.4, miniPlayer.size.width * 0.4))
                    miniPlayer.physicsBody?.isDynamic = true
                    miniPlayer.physicsBody?.affectedByGravity = true
                    miniPlayer.physicsBody?.mass = 0
                    miniPlayer.physicsBody?.friction = 0
                    miniPlayer.physicsBody?.restitution = 1
                    self.addChild(miniPlayer)
                    miniPlayerAmount += 1
                }
            }
        } else if score <= 250 {
            if score == 0 {
                // more 'finishing touches' :^)
                let sadRock = SKSpriteNode(imageNamed: "debris-2")
                sadRock.size = CGSize(width: self.size.width / 8, height: self.size.width / 8)
                
                let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (sadRock.size.width))), highestValue: Int((self.size.width / 2) - (sadRock.size.width)))
                let positionX = CGFloat(randomXPosition.nextInt())
                let randomYPosition = GKRandomDistribution(lowestValue: Int(self.size.height / 6), highestValue: Int(self.size.height / 2))
                let positionY = CGFloat(randomYPosition.nextInt())
                
                sadRock.position = CGPoint(x: positionX, y: positionY)
                sadRock.physicsBody = SKPhysicsBody(circleOfRadius: max(sadRock.size.width * 0.6, sadRock.size.height * 0.6))
                sadRock.physicsBody?.isDynamic = true
                sadRock.physicsBody?.affectedByGravity = true
                sadRock.physicsBody?.mass = 100
                sadRock.physicsBody?.restitution = 0
                self.addChild(sadRock)
                
                let sadRockLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
                sadRockLabel.text = "you get the sad rock"
                sadRockLabel.fontSize = 24
                
                self.run(SKAction.wait(forDuration: 2.5)) {
                    sadRockLabel.position = CGPoint(x: sadRock.position.x, y: sadRock.position.y + (sadRock.size.height / 2))
                    self.addChild(sadRockLabel)
                }
            } else if score == 69 {
                // last (and best) of my 'finishing touches' :^)
                while miniPlayerAmount < score {
                    let miniPlayer = SKSpriteNode(imageNamed: "lennyFace")
                    miniPlayer.size = CGSize(width: self.size.width / 12, height: self.size.width / 12)
                    
                    let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (miniPlayer.size.width / 2))), highestValue: Int((self.size.width / 2) - (miniPlayer.size.width / 2)))
                    let positionX = CGFloat(randomXPosition.nextInt())
                    let randomYPosition = GKRandomDistribution(lowestValue: Int(self.size.height / 6), highestValue: Int(self.size.height / 2))
                    let positionY = CGFloat(randomYPosition.nextInt())
                    
                    miniPlayer.position = CGPoint(x: positionX, y: positionY)
                    miniPlayer.physicsBody = SKPhysicsBody(circleOfRadius: miniPlayer.size.width * 0.4)
                    miniPlayer.physicsBody?.isDynamic = true
                    miniPlayer.physicsBody?.affectedByGravity = true
                    miniPlayer.physicsBody?.mass = 0
                    miniPlayer.physicsBody?.friction = 0
                    miniPlayer.physicsBody?.restitution = 1
                    self.addChild(miniPlayer)
                    miniPlayerAmount += 1
                }
            } else if score != 69 {
                while miniPlayerAmount < score {
                    let miniPlayer = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: "playerTexture")!)
                    miniPlayer.size = CGSize(width: self.size.width / 12, height: self.size.width / 6)
                    
                    let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (miniPlayer.size.width / 2))), highestValue: Int((self.size.width / 2) - (miniPlayer.size.width / 2)))
                    let positionX = CGFloat(randomXPosition.nextInt())
                    let randomYPosition = GKRandomDistribution(lowestValue: Int(self.size.height / 6), highestValue: Int(self.size.height / 2))
                    let positionY = CGFloat(randomYPosition.nextInt())
                    
                    miniPlayer.position = CGPoint(x: positionX, y: positionY)
                    miniPlayer.physicsBody = SKPhysicsBody(circleOfRadius: miniPlayer.size.width * 0.4)
                    miniPlayer.physicsBody?.isDynamic = true
                    miniPlayer.physicsBody?.affectedByGravity = true
                    miniPlayer.physicsBody?.mass = 0
                    miniPlayer.physicsBody?.friction = 0
                    miniPlayer.physicsBody?.restitution = 1
                    self.addChild(miniPlayer)
                    miniPlayerAmount += 1
                }
            }
        }
    }
}
