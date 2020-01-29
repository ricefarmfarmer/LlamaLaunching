//
//  CreditsViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/22/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit
import GameKit

class CreditsViewController: UIViewController {
    
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var starsView: SKView!
    
    var blinkStatus = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creditsLabel.adjustsFontSizeToFitWidth = true
        creditsLabel.numberOfLines = 18
        
        bottomLabel.adjustsFontSizeToFitWidth = true
        bottomLabel.lineBreakMode = .byClipping
        bottomLabel.numberOfLines = 1
        
        let starsScene = StarsScene(size: starsView.bounds.size)
        starsScene.scaleMode = .aspectFill
        starsView.presentScene(starsScene)
        
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.5), target: self, selector: #selector(blinkingAction), userInfo: nil, repeats: true)
        blinkStatus = false
        
        timer.fire()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func blinkingAction() {
        if blinkStatus == false {
            UIView.animate(withDuration: 1.5, delay: 0, animations: {
                self.bottomLabel.alpha = 1
            }, completion: nil)
            blinkStatus = true
        } else if blinkStatus == true {
            UIView.animate(withDuration: 1.5, delay: 0, animations: {
                self.bottomLabel.alpha = 0
            }, completion: nil)
            blinkStatus = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

class StarsScene: SKScene {
    
    var stars: SKEmitterNode!
    
    override func didMove(to view: SKView) {
        stars = SKEmitterNode(fileNamed: "stars")
        stars.position = CGPoint(x: 0, y: 0)
        stars.advanceSimulationTime(30)
        stars.zPosition = -1
        stars.physicsBody?.isDynamic = false
        self.addChild(stars)
    }
}
