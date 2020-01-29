//
//  GameScene.swift
//  Llama Launching
//
//  Created by Branden Yang on 4/26/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var scoreLabel : SKLabelNode!
    var highScoreLabel : SKLabelNode!
    var titleLabel : SKLabelNode!
    var startLabel : SKLabelNode!
    var coinLabel : SKLabelNode!
    var coinImage : SKSpriteNode!
    var player : SKSpriteNode!
    var planet : SKSpriteNode!
    var touchArea : SKSpriteNode!
    var arrowIndicator : SKSpriteNode!
    var indicator : SKSpriteNode!
    var indicator2 : SKSpriteNode!
    var redLine : SKSpriteNode!
    var bottomBar : SKSpriteNode!
    var gameCenterButton : SKSpriteNode!
    var settingsButton : SKSpriteNode!
    var shopButton : SKSpriteNode!
    var equipButton : SKSpriteNode!
//    var pauseButton : SKSpriteNode!
//    var pauseView : SKSpriteNode!
    
    var originalLocation : CGPoint!
    var indicatorLocation : CGPoint!
    var planetDestroyed : Bool = false
    var playerFirstLaunch : Bool = false
    var highScoreUpdatedThisRound: Bool = false
    var touchesBegan : Bool = false
    var spawnEnemiesTimer : Timer!
    var playerImpulseTimer : Timer!
    var stars : SKEmitterNode!
    var score : Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var highScore : Int = UserDefaults.standard.integer(forKey: "highScore")
    var coins : Int = UserDefaults.standard.integer(forKey: "coins")
    var debrisImages = [SKTexture]() // Possible enemies/debris (images)
//    var blinkingStartLabelArray = [SKAction]()
    
    enum PhysicsCategory : UInt32 {
        case player = 1
        case border = 2
        case planet = 4
        case debrisTrail = 8
        case debris = 16
    }
    
    var changedDebrisSpawnTime : Bool = false // If you change the debris spawn time, it cannot be changed more than once per score (we change this back when we change the score)
    var changedOnce : Bool = false
    private var spawnTime = 1.75
    private var priorDebrisAddTime : TimeInterval = 0
    private var nextDebrisAddTime : TimeInterval { // If this value is less than the currentTime in update, then priorDebrisAddTime is set to currentTime and a debris is spawned - basically we spawn a debris every waitTime.
        let spawnIncreaseFactor = (score % 10 == 0) && (score != 0) ? 0.95
            : (score % 100 == 0) && (score != 0) ? 0.85
            : (score % 1000 == 0) && (score != 0) ? 0.75
            : 1.0
        
        if spawnIncreaseFactor != 1.0 && changedOnce == false {
            changedDebrisSpawnTime = true
        }
        
        if changedDebrisSpawnTime == true && changedOnce == false {
            spawnTime = spawnTime * spawnIncreaseFactor
            print("Time between debris: \(spawnTime)")
            changedOnce = true
        }
        
        let waitTime = spawnTime
        
//        let waitTime = score < 25 ? 2.0
//            : score < 100 ? 1.0
//            : score < 250 ? 0.85
//            : score < 500 ? 0.7
//            : score < 1000 ? 0.55
//            : 0.4
        
        return priorDebrisAddTime + waitTime
    }
    
//    GameCenter stuff
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    let LEADERBOARD_ID = "com.BrandenYang.LlamaLaunching"
    
//    Sound Effects
    var debrisExplosion = SKAudioNode()
    var planetExplosion = SKAudioNode()
    var planetExplosionTwo = SKAudioNode()
    var planetExplosionThree = SKAudioNode()
    
//    Background Music
    var backgroundMusic = SKAudioNode()
    
//    Play count
    var playCount = Int()
    
//    First launch
    var firstLaunch = Bool()
    
//        Safe area insets for sizing on iPhone X and more
    private var insets: UIEdgeInsets? {
        if #available(iOS 11.0, *) {
            return self.view?.safeAreaInsets
        }
        return .zero
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scene?.scaleMode = SKSceneScaleMode.aspectFit
        
        let fontName = "VCR OSD Mono"
        
//        Update local play count
        playCount = 0
        playCount = UserDefaults.standard.integer(forKey: "playCount")
        
//        Create stars background emitter node
        stars = SKEmitterNode(fileNamed: "stars")
        stars.position = CGPoint(x: 0, y: 0)
        stars.advanceSimulationTime(30)
        stars.zPosition = -2
        stars.physicsBody?.isDynamic = false
        self.addChild(stars)
        
//        Create score label
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontSize = 200
        scoreLabel.fontColor = UIColor.white
        scoreLabel.alpha = 0.0
        scoreLabel.position = CGPoint(x: 0, y: 0 + (self.size.height / 3))
        scoreLabel.physicsBody?.isDynamic = false
        scoreLabel.zPosition = -1
        self.addChild(scoreLabel)
        scoreLabel.text = "0"
        
//        Create high score label
        highScoreLabel = SKLabelNode(fontNamed: fontName)
        highScoreLabel.fontSize = 200
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.alpha = 1.0
        highScoreLabel.position = CGPoint(x: 0, y: 0)
        highScoreLabel.physicsBody?.isDynamic = false
        highScoreLabel.zPosition = -1
        self.addChild(highScoreLabel)
        highScoreLabel.text = "High Score: "
        
//        Create start game label (titleLabel)
        titleLabel = SKLabelNode(fontNamed: fontName)
        titleLabel.fontSize = 200
        titleLabel.fontColor = UIColor.white
        titleLabel.alpha = 0.0
        titleLabel.run(SKAction.fadeIn(withDuration: 2.0))
        titleLabel.position = CGPoint(x: 0, y: 0 + (self.size.height / 3))
        titleLabel.physicsBody?.isDynamic = false
        self.addChild(titleLabel)
        titleLabel.text = "Llama Launching"
        
//        Create blinking 'Tap to begin' label
        startLabel = SKLabelNode(fontNamed: fontName)
        startLabel.fontSize = 200
        startLabel.fontColor = UIColor.white
        startLabel.alpha = 1.0
        startLabel.physicsBody?.isDynamic = false
        
        var blinkingStartLabelArray = [SKAction]()
        
        blinkingStartLabelArray.append(SKAction.fadeAlpha(to: 0.0, duration: 1.0))
        blinkingStartLabelArray.append(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
        blinkingStartLabelArray.append(SKAction.wait(forDuration: 1.5))
        
        startLabel.run(SKAction.repeatForever(SKAction.sequence(blinkingStartLabelArray)))
        
        startLabel.position = CGPoint(x: 0, y: 0 - (self.size.height / 6))
        self.addChild(startLabel)
        self.startLabel.text = "Tap to begin"
        
//        Create coin image & label
        coinImage = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "coin")), size: CGSize(width: self.size.width / 16, height: self.size.width / 16))
        coinImage.position = CGPoint(x: 0 - (self.size.width / 2) + (coinImage.size.width), y: 0 + (self.size.height / 2) - (coinImage.size.height))
        coinImage.physicsBody?.affectedByGravity = false
        coinImage.physicsBody?.isDynamic = false
        coinImage.zPosition = -1
        coinImage.alpha = 1.0
        self.addChild(coinImage)
        
        coinLabel = SKLabelNode(fontNamed: fontName)
        coinLabel.fontSize = 100
        coinLabel.fontColor = UIColor.white
        coinLabel.zPosition = -1
        coinLabel.alpha = 1.0
        coinLabel.physicsBody?.isDynamic = false
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: coinImage.position.x + (coinImage.size.width * 0.65), y: coinImage.position.y - ((coinImage.size.height * 0.8) / 2))
        self.addChild(coinLabel)
        self.coinLabel.text = "0"
        
//        Create planet
        self.planet = self.childNode(withName: "planet") as? SKSpriteNode
        if let planet = self.planet {
            let sizeValue = (self.size.width) * 1.15
            planet.texture = SKTexture.init(image: #imageLiteral(resourceName: "planet-green"))
            planet.size = CGSize.init(width: sizeValue, height: sizeValue)
            planet.position = CGPoint(x: 0, y: 0 - ((self.size.height * 1.25) / 2))
            planet.physicsBody = SKPhysicsBody(circleOfRadius: max(planet.size.width / 2, planet.size.height / 2))
            
            planet.physicsBody?.affectedByGravity = false
            planet.physicsBody?.isDynamic = true
            planet.physicsBody?.pinned = true
            planet.physicsBody?.friction = 1
            planet.physicsBody?.restitution = 1
            planet.physicsBody?.angularDamping = 0
            planet.physicsBody?.mass = 50
            planet.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

            planet.physicsBody?.categoryBitMask = PhysicsCategory.planet.rawValue
            planet.physicsBody?.contactTestBitMask = PhysicsCategory.debris.rawValue
            planet.physicsBody?.collisionBitMask = PhysicsCategory.planet.rawValue
            planet.physicsBody?.usesPreciseCollisionDetection = true
            
            planet.alpha = 1
            planet.zPosition = -1
        }
        
//        Create player
        let width = (self.size.width) * 0.06
        let height = (self.size.width) * 0.12
        let playerSize = CGSize.init(width: width, height: height)
        let playerTextureName = UserDefaults.standard.string(forKey: "playerTexture") ?? "llama"
        let playerTexture = SKTexture(imageNamed: playerTextureName)
        player = SKSpriteNode(texture: playerTexture)
        
        // I was following whatever apple docs had on physicsbodies here so just ignore this code
        //let llamaNode = SKSpriteNode(texture: llamaTexture)
        //llamaNode.physicsBody = SKPhysicsBody(circleOfRadius: max(llamaNode.size.width / 2, llamaNode.size.height / 2))
        //player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: llamaNode.size.width, height: llamaNode.size.width))
        player.physicsBody = SKPhysicsBody(circleOfRadius: max(player.size.width * 0.2, player.size.height * 0.2))
        
        player.position = CGPoint(x: 0, y: planet.position.y + (planet.size.height / 2) + (player.size.height / 3))
        player.size = playerSize
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.mass = 1
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.linearDamping = 0
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        player.physicsBody?.collisionBitMask = PhysicsCategory.border.rawValue | PhysicsCategory.planet.rawValue
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.zPosition = 0
        self.addChild(player)
        
        // infinitely rotate planet
        let oneRevolution : SKAction = SKAction.rotate(byAngle: -(CGFloat.pi * 2), duration: 60)
        let infiniteRotation : SKAction = SKAction.repeatForever(oneRevolution)
        planet.run(infiniteRotation)
        
//        Create touchArea
        let touchAreaColor = UIColor.white
        let touchAreaSize = CGSize(width: self.size.width, height: self.size.height)
        
        touchArea = SKSpriteNode(color: touchAreaColor, size: touchAreaSize)
        touchArea.physicsBody?.affectedByGravity = false
        touchArea.physicsBody?.isDynamic = false
        touchArea.physicsBody?.pinned = true
        touchArea.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        touchArea.position = CGPoint(x: 0, y: 0)
        touchArea.zPosition = 2
        touchArea.alpha = 0.01
        self.addChild(touchArea)
        
//        Create bottom bar
        bottomBar = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: (self.size.width / 4)))
        bottomBar.position = CGPoint(x: 0, y: 0 - (self.size.height / 2) + (bottomBar.size.height / 2))
        bottomBar.physicsBody?.affectedByGravity = false
        bottomBar.physicsBody?.isDynamic = false
        bottomBar.zPosition = 3
        bottomBar.alpha = 0.8
        self.addChild(bottomBar)
        
//        Create leaderboard button
        gameCenterButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "leaderboardIcon")), size: CGSize(width: self.size.width / 8, height: self.size.width / 8))
        gameCenterButton.position = CGPoint(x: (0 - (self.size.width / 2)) + (gameCenterButton.size.width / 2) + (self.size.width * 0.05), y: (0 - (self.size.height / 2)) + (gameCenterButton.size.height / 2) + (self.size.width * 0.05))
        gameCenterButton.physicsBody?.affectedByGravity = false
        gameCenterButton.physicsBody?.isDynamic = true
        gameCenterButton.zPosition = 4
        gameCenterButton.alpha = 1.0
        self.addChild(gameCenterButton)
        
//        Create settings button
        settingsButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "settingsIcon")), size: CGSize(width: self.size.width / 8, height: self.size.width / 8))
        settingsButton.position = CGPoint(x: (gameCenterButton.position.x) + (settingsButton.size.width) + (self.size.width * 0.05), y: gameCenterButton.position.y)
        settingsButton.physicsBody?.affectedByGravity = false
        settingsButton.physicsBody?.isDynamic = true
        settingsButton.zPosition = 4
        settingsButton.alpha = 1.0
        self.addChild(settingsButton)
        
//        Create shop button
        shopButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "shopIcon")), size: CGSize(width: self.size.width / 8, height: self.size.width / 8))
        shopButton.position = CGPoint(x: (0 + (self.size.width / 2)) - (shopButton.size.width / 2) - (self.size.width * 0.05), y: gameCenterButton.position.y)
        shopButton.physicsBody?.affectedByGravity = false
        shopButton.physicsBody?.isDynamic = true
        shopButton.zPosition = 4
        shopButton.alpha = 1.0
        self.addChild(shopButton)
        
//        Create equip button
        equipButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "equipIcon")), size: CGSize(width: self.size.width / 8, height: self.size.width / 8))
        equipButton.position = CGPoint(x: (shopButton.position.x) - (equipButton.size.width) - (self.size.width * 0.05), y: gameCenterButton.position.y)
        equipButton.physicsBody?.affectedByGravity = false
        equipButton.physicsBody?.isDynamic = true
        equipButton.zPosition = 4
        equipButton.alpha = 1.0
        self.addChild(equipButton)
        
//        Create pause/play button
//        pauseButton = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "pause")), size: CGSize(width: self.size.width / 8, height: self.size.width / 8))
//        pauseButton.position = CGPoint(x: (0 + (self.size.width / 2)) - (pauseButton.size.width) - (self.size.width * 0.05), y: (0 + (self.size.height / 2)) - (pauseButton.size.height) - (self.size.width * 0.05))
//        pauseButton.physicsBody?.affectedByGravity = false
//        pauseButton.physicsBody?.isDynamic = true
//        pauseButton.zPosition = 4
//        pauseButton.alpha = 0
//        self.addChild(pauseButton)
        
//        Create pause view
//        pauseView = SKSpriteNode(color: UIColor.darkGray, size: self.size)
//        pauseView.physicsBody?.affectedByGravity = false
//        pauseView.physicsBody?.isDynamic = false
//        pauseView.physicsBody?.pinned = true
//        pauseView.zPosition = 3
//        pauseView.alpha = 0
//        self.addChild(pauseView)
        
//        Create arrow indicator
        arrowIndicator = SKSpriteNode(color: UIColor.clear, size: CGSize(width: (self.size.width) * 0.12, height: (self.size.width) * 0.24))
        arrowIndicator.physicsBody?.affectedByGravity = false
        arrowIndicator.physicsBody?.isDynamic = false
        arrowIndicator.alpha = 0
        
        let arrow = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "arrow")), size: CGSize(width: (self.size.width) * 0.12, height: (self.size.width) * 0.12))
        arrow.position = CGPoint(x: arrowIndicator.position.x, y: arrowIndicator.position.y + arrowIndicator.size.height / 2)
        arrowIndicator.addChild(arrow)
        
        self.addChild(arrowIndicator)
        
//        Create indicator 1 (for touchArea)
        let indicatorTexture = SKTexture(image: #imageLiteral(resourceName: "circle"))
        let indicatorSize = CGSize(width: height, height: height)
        
        indicator = SKSpriteNode(texture: indicatorTexture, size: indicatorSize)
        indicator.physicsBody?.affectedByGravity = false
        indicator.physicsBody?.isDynamic = false
        indicator.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        indicator.zPosition = 1
        indicator.alpha = 0
        self.addChild(indicator)
        
//        Create indicator 2 (for touchArea)
        let indicatorTexture2 = SKTexture(image: #imageLiteral(resourceName: "circle 2"))
        
        indicator2 = SKSpriteNode(texture: indicatorTexture2, size: indicatorSize)
        indicator2.physicsBody?.affectedByGravity = false
        indicator2.physicsBody?.isDynamic = false
        indicator2.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        indicator2.zPosition = 1
        indicator2.alpha = 0
        self.addChild(indicator2)
        
//        Create red line (to show where meteors cannot pass)
        redLine = SKSpriteNode(color: UIColor.red, size: CGSize(width: self.size.width, height: 5))
        redLine.position = CGPoint(x: 0, y: (planet.position.y) + ((planet.size.height) / 2))
        redLine.physicsBody?.isDynamic = false
        redLine.physicsBody?.affectedByGravity = false
        self.addChild(redLine)
        
//        Create border around screen (so llama doesn't fly off into space)
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.categoryBitMask = PhysicsCategory.border.rawValue
        border.collisionBitMask = PhysicsCategory.player.rawValue
        self.physicsBody = border
        
//        Create sound effects
        planetExplosion = SKAudioNode(fileNamed: "explosion-long.wav")
        planetExplosion.autoplayLooped = false
        planetExplosion.run(SKAction.changeVolume(to: 1.0, duration: 0))
        planet.addChild(planetExplosion)
        
        planetExplosionTwo = SKAudioNode(fileNamed: "explosion-long.wav")
        planetExplosionTwo.autoplayLooped = false
        planetExplosionTwo.run(SKAction.changeVolume(to: 1.0, duration: 0))
        planet.addChild(planetExplosionTwo)
        
        planetExplosionThree = SKAudioNode(fileNamed: "explosion-long.wav")
        planetExplosionThree.autoplayLooped = false
        planetExplosionThree.run(SKAction.changeVolume(to: 1.0, duration: 0))
        planet.addChild(planetExplosionThree)
        
//        Create background music audio player
        backgroundMusic = SKAudioNode(fileNamed: "final-sacrifice.wav")
        backgroundMusic.autoplayLooped = false
        backgroundMusic.run(SKAction.changeVolume(to: 0.4, duration: 0))
        self.addChild(backgroundMusic)
        
//        Sizing constraints
        while titleLabel.frame.width < self.frame.width * 0.85 {
            titleLabel.fontSize += 5
        }
        while titleLabel.frame.width > self.frame.width * 0.85 {
            titleLabel.fontSize -= 5
        }
        
        while scoreLabel.frame.height < self.frame.height * 0.1 {
            scoreLabel.fontSize += 5
        }
        while scoreLabel.frame.height > self.frame.height * 0.1 {
            scoreLabel.fontSize -= 5
        }
        
        while highScoreLabel.frame.width < titleLabel.frame.width / 2 {
            highScoreLabel.fontSize += 5
        }
        while highScoreLabel.frame.width > titleLabel.frame.width / 2 {
            highScoreLabel.fontSize -= 5
        }
        
        while startLabel.frame.width < self.frame.width * 0.4 {
            startLabel.fontSize += 5
        }
        while startLabel.frame.width > self.frame.width * 0.4 {
            startLabel.fontSize -= 5
        }
        
        while coinLabel.frame.height < coinImage.size.height * 0.8 {
            coinLabel.fontSize += 5
        }
        while coinLabel.frame.height > coinImage.size.height * 0.8 {
            coinLabel.fontSize -= 5
        }
        
//        Set booleans to beginning values just to be safe
        planetDestroyed = false
        playerFirstLaunch = false
        highScoreUpdatedThisRound = false
        UserDefaults.standard.set(highScoreUpdatedThisRound, forKey: "highScoreUpdated")
        
//        The below is to clear out the empty string
        debrisImages.removeAll()
        
//        Standard debris:
        debrisImages.append(SKTexture(image: #imageLiteral(resourceName: "debris-1")))
        debrisImages.append(SKTexture(image: #imageLiteral(resourceName: "debris-2")))
        debrisImages.append(SKTexture(image: #imageLiteral(resourceName: "debris-3")))
        
//        If _ set has been purchased, append _ images from the specific set's image array (to be created) to debrisImages
        
//        Check if player is signed into GameCenter
        authenticateLocalPlayer()
        
//        Default settings (if first time in app)
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            print("Has launched app before")
        } else {
            print("First time launching app")
            
            UserDefaults.standard.set(true, forKey: "launchedBefore") // no longer first time in app
            UserDefaults.standard.set(true, forKey: "redLineIndicatorOn") // default is for redLineIndicator to be on
            UserDefaults.standard.set(true, forKey: "arrowIndicatorOn") // default is for arrowIndicator to be on
            UserDefaults.standard.set(true, forKey: "soundEffectsOn") // default is for sf to be on
            UserDefaults.standard.set(true, forKey: "backgroundMusicOn") // default is for bgm to be on
        }
        
//        things that need to be updated/done last
        highScore = UserDefaults.standard.integer(forKey: "highScore")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.position = CGPoint(x: 0, y: titleLabel.position.y - highScoreLabel.frame.height)
        
        coins = UserDefaults.standard.integer(forKey: "coins")
        coinLabel.text = "\(coins)"
        coinLabel.position = CGPoint(x: coinImage.position.x + (coinImage.size.width * 0.65), y: coinImage.position.y - (coinImage.size.height * 0.4))
        
        if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == true {
            redLine.alpha = 0.5
        } else if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == false {
            redLine.alpha = 0
        }
        if UserDefaults.standard.bool(forKey: "backgroundMusicOn") == true {
            backgroundMusic.autoplayLooped = true
            backgroundMusic.run(SKAction.play())
        } else if UserDefaults.standard.bool(forKey: "backgroundMusicOn") == false {
            backgroundMusic.autoplayLooped = false
            backgroundMusic.run(SKAction.stop())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchedWhere = nodes(at: touchLocation)
            
            if !touchedWhere.isEmpty {
                if let sprite = touchedWhere.first as? SKSpriteNode {
                    if self.touchArea == sprite {
                        guard self.touchArea == sprite else {
                            return
                        }
                        
                        touchesBegan = true
                        playerFirstLaunch = true
                        
                        // Change the alpha of the other elements on the screen
                        scoreLabel.run(SKAction.fadeIn(withDuration: 1.0))
//                        pauseButton.run(SKAction.fadeIn(withDuration: 1.0))
                        titleLabel.run(SKAction.fadeOut(withDuration: 1.0))
                        gameCenterButton.run(SKAction.fadeOut(withDuration: 1.0))
                        settingsButton.run(SKAction.fadeOut(withDuration: 1.0))
                        shopButton.run(SKAction.fadeOut(withDuration: 1.0))
                        equipButton.run(SKAction.fadeOut(withDuration: 1.0))
                        bottomBar.run(SKAction.fadeOut(withDuration: 1.0))
                        
                        // Also need to disable them apparently
                        self.run(SKAction.wait(forDuration: 2.0)) {
                            self.titleLabel.removeFromParent()
                            self.gameCenterButton.removeFromParent()
                            self.settingsButton.removeFromParent()
                            self.shopButton.removeFromParent()
                            self.equipButton.removeFromParent()
                            self.bottomBar.removeFromParent()
                        }
                        
                        // Start the blinking red line animation (only if setting for redLineIndicatorOn == true)
                        if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == true {
                            var blinkingRedLineArray = [SKAction]()
                            
                            blinkingRedLineArray.append(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
                            blinkingRedLineArray.append(SKAction.fadeAlpha(to: 0.5, duration: 1.0))
                            
                            redLine.run(SKAction.repeatForever(SKAction.sequence(blinkingRedLineArray)))
                        } else if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == false {
                            redLine.alpha = 0
                        }
                        
                        // Make the previous blinkingStartLabel animations stop here
                        startLabel.run(SKAction.sequence([SKAction.fadeOut(withDuration: 2.0), SKAction.run {
                            self.startLabel.isHidden = true
                        }]))
                        
                        // Makes the player completely stop moving upon first touch
                        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        
                        // Set the originalLocation to the current touch location (for launch)
                        originalLocation = CGPoint(x: (touches.first?.location(in: self).x)!, y: (touches.first?.location(in: self).y)!)
                        
                        // Set the indicator location to the same place
                        indicatorLocation = CGPoint(x: (touches.first?.location(in: self).x)!, y: (touches.first?.location(in: self).y)!)
                        
                        // Indicator stuff
                        indicator.position = indicatorLocation
                        indicator2.position = indicatorLocation
                        indicator.alpha = 1
                        indicator2.alpha = 1
                        
                        // player rotation code
                        let DegreesToRadians = CGFloat.pi / 180
                        
                        if let player = self.player {
                            for touch in touches {
                                let position = touch.location(in: self)
                                let target = CGPoint(x: (self.indicator.position.x), y: (self.indicator.position.y))
                                
                                let deltaX = CGFloat(target.y - position.y)
                                let deltaY = CGFloat(target.x - position.x)
                                let angle = atan2(deltaY, deltaX)
                                player.zRotation = -(angle + 1 * DegreesToRadians)
                            }
                        }
                        
                        // Do the same for the arrow indicator as we do for the red line
                        if UserDefaults.standard.bool(forKey: "arrowIndicatorOn") == true {
                            arrowIndicator.size = CGSize(width: (self.size.width) * 0.12, height: (self.size.width) * 0.12)
                            arrowIndicator.position = CGPoint(x: player.position.x, y: player.position.y)
                            arrowIndicator.alpha = 1
                            arrowIndicator.zRotation = player.zRotation
                        } else if UserDefaults.standard.bool(forKey: "arrowIndicatorOn") == false {
                            arrowIndicator.alpha = 0
                        }
                    } else if self.gameCenterButton == sprite {
                        showLeaderboard()
                    } else if self.settingsButton == sprite {
                        showSettings()
                    } else if self.shopButton == sprite {
                        showShop()
                    } else if self.equipButton == sprite {
                        showEquip()
                    }
//                    else if self.pauseButton == sprite {
//                        togglePauseGame()
//                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let DegreesToRadians = CGFloat.pi / 180
        
        // Update the indicator's position to finger movement
        indicatorLocation = CGPoint(x: (touches.first?.location(in: self).x)!, y: (touches.first?.location(in: self).y)!)
        indicator2.position = indicatorLocation
        
        // Player rotation code
        if let player = self.player {
            for touch in touches {
                let position = touch.location(in: self)
                let target = CGPoint(x: (self.indicator.position.x), y: (self.indicator.position.y))
                
                let deltaX = CGFloat(target.y - position.y)
                let deltaY = CGFloat(target.x - position.x)
                let angle = atan2(deltaY, deltaX)
                player.zRotation = -(angle + 1 * DegreesToRadians)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "arrowIndicatorOn") == true {
            arrowIndicator.size = CGSize(width: (self.size.width) * 0.12, height: (self.size.width) * 0.12)
            arrowIndicator.position = CGPoint(x: player.position.x, y: player.position.y)
            arrowIndicator.alpha = 1
            arrowIndicator.zRotation = player.zRotation
        } else if UserDefaults.standard.bool(forKey: "arrowIndicatorOn") == false {
            arrowIndicator.alpha = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        arrowIndicator.alpha = 0
        indicator.alpha = 0
        indicator2.alpha = 0
        indicator.position = CGPoint(x: 0, y: 0)
        indicator2.position = CGPoint(x: 0, y: 0)
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchedWhere = nodes(at: touchLocation)
            
            if !touchedWhere.isEmpty {
                for node in touchedWhere {
                    if let sprite = node as? SKSpriteNode {
                        guard self.touchArea == sprite else {
                            return
                        }
                        
                        // 'touchesBegan' is so that if you start the touch off of the touchArea and end it on it, the game doesn't crash (launch only works if start and finish are on touchArea)
                        if touchesBegan {
                            let dx = -(touchLocation.x - originalLocation.x)
                            let dy = -(touchLocation.y - originalLocation.y)
                            
                            let impulse = CGVector(dx: dx * 3, dy: dy * 3)
                        
                            if planetDestroyed == false {
                                let playerEffect = SKEmitterNode(fileNamed: "player")!
                                playerEffect.position = player.position
                                playerEffect.zRotation = player.zRotation
                                self.addChild(playerEffect)
                                
                                self.player.physicsBody?.applyImpulse(impulse)
                                
                                self.run(SKAction.wait(forDuration: 1)) {
                                    playerEffect.removeFromParent()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Where firstBody is the player and secondBody is the debris
        if (firstBody.categoryBitMask & PhysicsCategory.player.rawValue) != 0 && (secondBody.categoryBitMask & PhysicsCategory.debris.rawValue) != 0 {
            // destroy the specific debris touched & play explosion skemitternode @ position of destroyed debris
            playerDidCollideWith(debris: secondBody.node as! SKSpriteNode)
            
            // Add 1 point to score and play effect
            if !planetDestroyed {
                score += 1
                changedDebrisSpawnTime = false
                changedOnce = false
                
                // Add 1 coin for every debris destroyed & update UserDefaults
                
                coins += 1
                UserDefaults.standard.set(coins, forKey: "coins")
                coinLabel.text = "\(coins)"
                
                // Update the userdefaults and the high score label
                if highScore < score {
                    highScore = score
                    UserDefaults.standard.set(highScore, forKey: "highScore")
                    saveAndSubmitHighScore(score: highScore)
                    highScoreUpdatedThisRound = true
                    UserDefaults.standard.set(highScoreUpdatedThisRound, forKey: "highScoreUpdated")
                }
                highScoreLabel.text = "High Score: \(highScore)"
                
                // Show a scoreEffect dependent on the score (if it's divisible by a certain #)
                if score % 10 == 0 {
                    if score % 100 == 0 {
                        if score % 1000 == 0 {
                            let scoreEffect = SKEmitterNode(fileNamed: "biggestscore")!
                            scoreEffect.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y + (scoreLabel.frame.height / 2))
                            self.addChild(scoreEffect)
                            
                            self.run(SKAction.wait(forDuration: 1)) {
                                scoreEffect.removeFromParent()
                            }
                        }
                        
                        let scoreEffect = SKEmitterNode(fileNamed: "biggerscore")!
                        scoreEffect.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y + (scoreLabel.frame.height / 2))
                        self.addChild(scoreEffect)
                        
                        self.run(SKAction.wait(forDuration: 1)) {
                            scoreEffect.removeFromParent()
                        }
                    }
                    
                    let scoreEffect = SKEmitterNode(fileNamed: "bigscore")!
                    scoreEffect.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y + (scoreLabel.frame.height / 2))
                    self.addChild(scoreEffect)
                    
                    self.run(SKAction.wait(forDuration: 1)) {
                        scoreEffect.removeFromParent()
                    }
                } else {
                    let scoreEffect = SKEmitterNode(fileNamed: "score")!
                    scoreEffect.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y + (scoreLabel.frame.height / 2))
                    self.addChild(scoreEffect)
                    
                    self.run(SKAction.wait(forDuration: 1)) {
                        scoreEffect.removeFromParent()
                    }
                }
            }
            
            // If time between debris destroyed is within 0.1 seconds, x2 points
            
            // If time between debris destroyed is within 0.05 seconds, x4 points
            
        }
        
        // Where firstBody is the player and secondBody is the particle (debrisTrail)
        if (firstBody.categoryBitMask & PhysicsCategory.player.rawValue) != 0 && (secondBody.categoryBitMask & PhysicsCategory.debrisTrail.rawValue) != 0 {
            // destroy the specific trail (debrisTrail) touched
            playerDidCollideWith(debrisTrail: secondBody.node as! SKEmitterNode)
        }
        
        // Where firstBody is the planet and secondBody is the debris
        if (firstBody.categoryBitMask & PhysicsCategory.planet.rawValue) != 0 && (secondBody.categoryBitMask & PhysicsCategory.debris.rawValue) != 0 {
            // destroy the planet and debris & play planetdeath skemitternode @ position of planet
            if !planetDestroyed {
                planetDidCollideWith(debris: secondBody.node as! SKSpriteNode)
            }
        }
    }
    
    func playerDidCollideWith(debris: SKSpriteNode) {
        // Explosion effect upon collision with player
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = debris.position
        
        self.addChild(explosion)
        
        // Play sound effect
        if UserDefaults.standard.bool(forKey: "soundEffectsOn") {
            player.run(SKAction.playSoundFileNamed("explosion-short.wav", waitForCompletion: false))
        }
        
        // Coin animation
        showCoinAnimation(coinPosition: debris.position)
        
        // Remove the debris hit (find a way to remove all debris on screen)
        debris.removeFromParent()
        
        // Wait until explosion finishes playing and remove
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
    }
    
    func playerDidCollideWith(debrisTrail: SKEmitterNode) {
        // Remove the particle (debrisTrail) hit
        debrisTrail.removeFromParent()
    }
    
    func planetDidCollideWith(debris: SKSpriteNode) {
        // Play planetdeath skemitternode @ position of planet
        let planetDeath = SKEmitterNode(fileNamed: "planetdeath")!
        planetDeath.position = (planet.position)
        
        self.addChild(planetDeath)
        
        // Play extremely intense explosion mashup (sound effect)
        if UserDefaults.standard.bool(forKey: "soundEffectsOn") {
            backgroundMusic.run(SKAction.stop())
            playSoundEffect(effect: planetExplosion, node: planet, delay: 0, removeAfter: 8)
            playSoundEffect(effect: planetExplosion, node: planet, delay: 4, removeAfter: 4)
            playSoundEffect(effect: planetExplosionTwo, node: planet, delay: 1, removeAfter: 7)
            playSoundEffect(effect: planetExplosionTwo, node: planet, delay: 5, removeAfter: 3)
            playSoundEffect(effect: planetExplosionThree, node: planet, delay: 2, removeAfter: 6)
        }
            
        // Move player to top of screen (random x value)
        player.physicsBody?.affectedByGravity = false
        let randomXPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (player.size.width / 2))), highestValue: Int((self.size.width / 2) - (player.size.width / 2)))
        let position = CGFloat(randomXPosition.nextInt())
        SKView.animate(withDuration: 4, animations: {
            self.player.run(SKAction.move(to: CGPoint(x: position, y: self.size.height / 2), duration: 0.5))
        })
        
        // Animate player to start spinning
        SKView.animate(withDuration: 8, animations: {
            self.player.physicsBody?.applyAngularImpulse(0.5)
            self.planet.physicsBody?.applyAngularImpulse(0)
        })
        
        // Fade out and remove planet after 8 seconds
        SKView.animate(withDuration: 8, animations: {
            self.planet.run(SKAction.fadeAlpha(to: 0.0, duration: 8))
            self.run(SKAction.wait(forDuration: 8)) {
                self.planet.removeFromParent()
            }
        })
        
        // Also remove ALL NODES
        self.run(SKAction.wait(forDuration: 8)) {
            self.removeAllChildren()
        }
        
        // Indicate planet has been destroyed so we can stop spawning debris & etc.
        planetDestroyed = true
        
        // Add one to playCount and update UserDefaults value
        playCount += 1
        UserDefaults.standard.set(playCount, forKey: "playCount")
        
        // Display end game screen
        self.run(SKAction.wait(forDuration: 8)) {
            self.gameOver()
        }
    }
    
    func playSoundEffect(effect: SKAudioNode, node: SKSpriteNode, delay: TimeInterval, removeAfter: TimeInterval) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run {
                effect.run(SKAction.play())
            },
            SKAction.wait(forDuration: removeAfter),
            SKAction.run {
                effect.removeFromParent()
            }
        ]))
    }
    
    @objc func addDebris() {
        // Shuffle array of debris images
        debrisImages = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: debrisImages) as! [SKTexture]
        let debrisSize = CGSize(width: (planet.size.width) / 8, height: (planet.size.height) / 8)
        let debris = SKSpriteNode(texture: debrisImages[0], size: debrisSize)
        
        let randomPosition = GKRandomDistribution(lowestValue: Int(0 - ((self.size.width / 2) - (debris.size.width / 2))), highestValue: Int((self.size.width / 2) - (debris.size.width / 2)))
        let position = CGFloat(randomPosition.nextInt())
        
        // Create debris
        debris.position = CGPoint(x: position, y: self.size.height + debris.size.height)
        debris.physicsBody = SKPhysicsBody(circleOfRadius: max(debris.size.width * 0.6, debris.size.height * 0.6))
        debris.physicsBody?.isDynamic = true
        debris.physicsBody?.angularVelocity = CGFloat(arc4random_uniform(4))
        
        debris.physicsBody?.restitution = 0
        debris.physicsBody?.friction = 0
        debris.physicsBody?.angularDamping = 0
        debris.physicsBody?.linearDamping = 0
        
        debris.physicsBody?.categoryBitMask = PhysicsCategory.debris.rawValue
        debris.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        debris.physicsBody?.collisionBitMask = 0
        debris.physicsBody?.usesPreciseCollisionDetection = true
        
        // Create debris trail
        let debrisTrail = SKEmitterNode(fileNamed: "debris")!
        debrisTrail.position = CGPoint(x: debris.position.x, y: debris.position.y)
        debrisTrail.physicsBody = SKPhysicsBody(circleOfRadius: max(debris.size.width * 0.6, debris.size.height * 0.6))
        debrisTrail.physicsBody?.isDynamic = true
        
        debrisTrail.physicsBody?.restitution = 0
        debrisTrail.physicsBody?.friction = 0
        debrisTrail.physicsBody?.angularDamping = 0
        debrisTrail.physicsBody?.linearDamping = 0
        debrisTrail.zPosition = -1
        
        debrisTrail.physicsBody?.categoryBitMask = PhysicsCategory.debrisTrail.rawValue
        debrisTrail.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        debrisTrail.physicsBody?.collisionBitMask = 0
        
        // Add the debris effect (and afterwards, the debris)
        self.addChild(debrisTrail)
        self.addChild(debris)
        
        // Change this to change the speed of the debris
        let varyingSpeed: TimeInterval = TimeInterval((2 * drand48()) - (2 * drand48()))
        var animationDuration: TimeInterval = 10
        
        if score < 25 {
            animationDuration = (10) + varyingSpeed
        } else if score >= 25 && score < 100 {
            animationDuration = (10 / 1.25) + varyingSpeed
        } else if score >= 100 && score < 250 {
            animationDuration = (10 / 1.5) + varyingSpeed
        } else if score >= 250 && score < 500 {
            animationDuration = (10 / 1.75) + varyingSpeed
        } else if score >= 500 && score < 1000 {
            animationDuration = (10 / 2.0) + varyingSpeed
        } else if score >= 1000 {
            animationDuration = (10 / 3.0) + varyingSpeed
        }
        
        
        // In case we decide we actually do want the speed to change every 10 or 20 or whatever
//        if (score % 10 == 0) && (score != 0) {
//            animationDuration = animationDuration * 0.95 + varyingSpeed
//        } else if (score % 100 == 0) && (score != 0) {
//            animationDuration = animationDuration * 0.85 + varyingSpeed
//        } else if (score % 500 == 0) && (score != 0) {
//            animationDuration = animationDuration * 0.75 + varyingSpeed
//        }
        
        var actionArray = [SKAction]()
        
        // Change this to change the end location of debris
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.size.height / 2), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        debris.run(SKAction.sequence(actionArray))
        debrisTrail.run(SKAction.sequence(actionArray))
    }
    
    func gameOver() {
        let transition = SKTransition.fade(withDuration: 2)
        let gameOverScene = SKScene(fileNamed: "GameOverScene") as! GameOverScene
        gameOverScene.scaleMode = .aspectFill
        gameOverScene.score = self.score
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    
    //    Pause/Play function
//    func togglePauseGame() {
//        if scene?.view?.isPaused == false {
//            pauseView.alpha = 0.6
//            scene?.view?.isPaused = true
//            // find a way to make the planet invulnerable for 3 second after pause because it breaks game - 1 idea is using UserDefaults + the function that updates every frame (bool that is true for 3 secs after pause)
//            planet.physicsBody?.isDynamic = false
//        } else if scene?.view?.isPaused == true {
//            pauseView.alpha = 0
//            scene?.view?.isPaused = false
//            // find a way to make the planet invulnerable for 1 second after pause because it breaks game
//        }
//    }
    
    // Honestly don't remember what this is for
//    func configureStartLabel() {
//        firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
//
//        if firstLaunch == false {
//            UserDefaults.standard.set(true, forKey: "firstLaunch")
//            firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
//            startLabel.text = "Loading..."
//            touchArea.alpha = 0
//            self.run(SKAction.wait(forDuration: 4.0)) {
//                self.startLabel.text = "Tap to continue"
//                self.touchArea.alpha = 0.01
//                self.startLabel.run(SKAction.repeatForever(SKAction.sequence(self.blinkingStartLabelArray)))
//            }
//        } else if firstLaunch == true {
//            startLabel.text = "Tap to continue"
//            touchArea.alpha = 0.01
//            startLabel.run(SKAction.repeatForever(SKAction.sequence(blinkingStartLabelArray)))
//        }
//    }
    
    //    Coin animation function
    func showCoinAnimation(coinPosition: CGPoint) {
        let coin = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "coin")), size: CGSize(width: coinImage.size.width, height: coinImage.size.height))
        coin.position = coinPosition
        
        var coinAction = [SKAction]()
        coinAction.append(SKAction.move(to: coinImage.position, duration: 1))
        coinAction.append(SKAction.run({
            SKAction.wait(forDuration: 1)
            SKAction.removeFromParent()
        }))
        
        if !planetDestroyed {
            self.addChild(coin)
            coin.run(SKAction.group(coinAction))
        }
    }
    
    //    GameCenter Functions
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                
                // 1. Show login if player is not logged in
                let rootVC = self.view?.window?.rootViewController
                rootVC?.present(ViewController!, animated: true, completion: nil)
                
            } else if (localPlayer.isAuthenticated) {
                
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
                
            }
        }
    }
    
    func saveAndSubmitHighScore(score : Int) {
        if GKLocalPlayer.local.isAuthenticated {
            let bestScore = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
            bestScore.value = Int64(score)
            
            GKScore.report([bestScore]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print ("Best score submitted to GameCenter Leaderboard")
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // Functions for buttons on 'main menu'
    
    func showLeaderboard() {
        let gameCenterVC = GKGameCenterViewController()
        
        gameCenterVC.gameCenterDelegate = self
        gameCenterVC.viewState = .leaderboards
        gameCenterVC.leaderboardIdentifier = LEADERBOARD_ID
        
        let rootVC = self.view?.window?.rootViewController
        rootVC?.present(gameCenterVC, animated: true, completion: nil)
    }
    
    func showSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        
        let rootVC = self.view?.window?.rootViewController
        rootVC?.present(settingsVC, animated: true, completion: nil)
    }
    
    func showShop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shopVC = storyboard.instantiateViewController(withIdentifier: "ShopViewController")
        
        let rootVC = self.view?.window?.rootViewController
        rootVC?.present(shopVC, animated: true, completion: nil)
        
        UserDefaults.standard.set(true, forKey: "hideCoins")
    }
    
    func showEquip() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shopVC = storyboard.instantiateViewController(withIdentifier: "EquipViewController")
        
        let rootVC = self.view?.window?.rootViewController
        rootVC?.present(shopVC, animated: true, completion: nil)
        
        UserDefaults.standard.set(true, forKey: "hideCoins")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        let playerTextureName = UserDefaults.standard.string(forKey: "playerTexture") ?? "llama"
        let playerTexture = SKTexture(imageNamed: playerTextureName)
        player.texture = playerTexture
        
        if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == true {
            redLine.alpha = 0.5
        } else if UserDefaults.standard.bool(forKey: "redLineIndicatorOn") == false {
            redLine.alpha = 0
        }
        
        if UserDefaults.standard.bool(forKey: "hideCoins") == true {
            coinImage.alpha = 0
            coinLabel.alpha = 0
        } else if UserDefaults.standard.bool(forKey: "hideCoins") == false {
            coinImage.alpha = 1
            coinLabel.alpha = 1
        }
        
        if !planetDestroyed {
            if UserDefaults.standard.bool(forKey: "backgroundMusicOn") == true {
                backgroundMusic.autoplayLooped = true
                backgroundMusic.run(SKAction.play())
            } else if UserDefaults.standard.bool(forKey: "backgroundMusicOn") == false {
                backgroundMusic.autoplayLooped = false
                backgroundMusic.run(SKAction.pause())
            }
        }
        
        coins = UserDefaults.standard.integer(forKey: "coins")
        coinLabel.text = "\(coins)"
        
        // Spawn enemies as long as planet has not been destroyed and player has done first launch
        if planetDestroyed == false && playerFirstLaunch == true {
            if nextDebrisAddTime <= currentTime {
                priorDebrisAddTime = currentTime
                addDebris()
            }
        }
    }
}
