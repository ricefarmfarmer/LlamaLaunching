//
//  GameViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 4/26/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadAndShowInterstitial), name: NSNotification.Name("loadAndShowInterstitial"), object: nil)
    }
    
//    Ad functions
    @objc func loadAndShowInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1777080001009552/3919132120")
        interstitial.delegate = self
        interstitial.load(GADRequest())
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if self.interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
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
