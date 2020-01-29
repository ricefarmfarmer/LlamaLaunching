//
//  TutorialPageThree.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/20/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit

class TutorialPageThree: UIViewController {

    @IBOutlet weak var GifView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var labelOne: UILabel!
    
    var blinkStatus = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GifView.loadGif(name: "tutorialGif3")
        
        continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
        continueButton.titleLabel?.numberOfLines = 1
        
        labelOne.adjustsFontSizeToFitWidth = true
        labelOne.lineBreakMode = .byClipping
        labelOne.numberOfLines = 5
        
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.5), target: self, selector: #selector(blinkingAction), userInfo: nil, repeats: true)
        blinkStatus = false
        
        timer.fire()
    }
    
    @objc func blinkingAction() {
        if blinkStatus == false {
            UIView.animate(withDuration: 1.5, delay: 0, animations: {
                self.continueButton.titleLabel?.alpha = 1
            }, completion: nil)
            blinkStatus = true
        } else if blinkStatus == true {
            UIView.animate(withDuration: 1.5, delay: 0, animations: {
                self.continueButton.titleLabel?.alpha = 0
            }, completion: nil)
            blinkStatus = false
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            self.dismiss(animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController")
            UIApplication.shared.keyWindow?.rootViewController = gameViewController
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
