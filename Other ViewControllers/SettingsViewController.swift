//
//  SettingsViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/19/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var settingOneButton: UIButton!
    @IBOutlet weak var settingTwoButton: UIButton!
    @IBOutlet weak var settingThreeButton: UIButton!
    @IBOutlet weak var settingFourButton: UIButton!
    @IBOutlet weak var settingFiveButton: UIButton!
    @IBOutlet weak var settingSixButton: UIButton!
    @IBOutlet weak var settingSevenButton: UIButton!
    
    @IBOutlet weak var settingOneLabel: UILabel!
    @IBOutlet weak var settingTwoLabel: UILabel!
    @IBOutlet weak var settingThreeLabel: UILabel!
    @IBOutlet weak var settingFourLabel: UILabel!
    @IBOutlet weak var settingFiveLabel: UILabel!
    @IBOutlet weak var settingSixLabel: UILabel!
    @IBOutlet weak var settingSevenLabel: UILabel!
    
    var redLineIndicatorOption = Bool()
    var arrowIndicatorOption = Bool()
    var soundEffectsOption = Bool()
    var backgroundMusicOption = Bool()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.lineBreakMode = .byClipping
        titleLabel.numberOfLines = 0
        
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.titleLabel?.lineBreakMode = .byClipping
        backButton.titleLabel?.numberOfLines = 1
        
        settingOneLabel.text = "Red Line Indicator"
        settingTwoLabel.text = "Arrow Indicator"
        settingThreeLabel.text = "Sound Effects"
        settingFourLabel.text = "Background Music"
        settingFiveLabel.text = "Tutorial"
        settingSixLabel.text = "Credits"
        settingSevenLabel.text = "Report a Bug"
        
        styleLabel(label: settingOneLabel)
        styleLabel(label: settingTwoLabel)
        styleLabel(label: settingThreeLabel)
        styleLabel(label: settingFourLabel)
        styleLabel(label: settingFiveLabel)
        styleLabel(label: settingSixLabel)
        styleLabel(label: settingSevenLabel)
        
        redLineIndicatorOption = UserDefaults.standard.bool(forKey: "redLineIndicatorOn")
        arrowIndicatorOption = UserDefaults.standard.bool(forKey: "arrowIndicatorOn")
        soundEffectsOption = UserDefaults.standard.bool(forKey: "soundEffectsOn")
        backgroundMusicOption = UserDefaults.standard.bool(forKey: "backgroundMusicOn")
        
        updateControlState(button: settingOneButton, setting: redLineIndicatorOption)
        updateControlState(button: settingTwoButton, setting: arrowIndicatorOption)
        updateControlState(button: settingThreeButton, setting: soundEffectsOption)
        updateControlState(button: settingFourButton, setting: backgroundMusicOption)
    }
    
    func styleLabel(label: UILabel) {
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
    }
    
    func updateControlState(button: UIButton, setting: Bool) {
        if setting {
            button.isSelected = true
            button.setImage(#imageLiteral(resourceName: "customSwitchOn"), for: .selected)
        } else if !setting {
            button.isSelected = false
            button.setImage(#imageLiteral(resourceName: "customSwitchOff"), for: .normal)
        }
    }
    
    // Red line indicator option
    @IBAction func settingOneAction(_ sender: Any) {
        if redLineIndicatorOption {
            UserDefaults.standard.set(false, forKey: "redLineIndicatorOn")
            settingOneButton.isSelected = false
            settingOneButton.setImage(#imageLiteral(resourceName: "customSwitchOff"), for: .normal)
        } else if !redLineIndicatorOption {
            UserDefaults.standard.set(true, forKey: "redLineIndicatorOn")
            settingOneButton.isSelected = true
            settingOneButton.setImage(#imageLiteral(resourceName: "customSwitchOn"), for: .selected)
        }
        redLineIndicatorOption = UserDefaults.standard.bool(forKey: "redLineIndicatorOn")
    }
    
    // Arrow indicator option
    @IBAction func settingTwoAction(_ sender: Any) {
        if arrowIndicatorOption {
            UserDefaults.standard.set(false, forKey: "arrowIndicatorOn")
            settingTwoButton.isSelected = false
            settingTwoButton.setImage(#imageLiteral(resourceName: "customSwitchOff"), for: .normal)
        } else if !arrowIndicatorOption {
            UserDefaults.standard.set(true, forKey: "arrowIndicatorOn")
            settingTwoButton.isSelected = true
            settingTwoButton.setImage(#imageLiteral(resourceName: "customSwitchOn"), for: .selected)
        }
        arrowIndicatorOption = UserDefaults.standard.bool(forKey: "arrowIndicatorOn")
    }
    
    // Sound effects option
    @IBAction func settingThreeAction(_ sender: Any) {
        if soundEffectsOption {
            UserDefaults.standard.set(false, forKey: "soundEffectsOn")
            settingThreeButton.isSelected = false
            settingThreeButton.setImage(#imageLiteral(resourceName: "customSwitchOff"), for: .normal)
        } else if !soundEffectsOption {
            UserDefaults.standard.set(true, forKey: "soundEffectsOn")
            settingThreeButton.isSelected = true
            settingThreeButton.setImage(#imageLiteral(resourceName: "customSwitchOn"), for: .selected)
        }
        soundEffectsOption = UserDefaults.standard.bool(forKey: "soundEffectsOn")
    }
    
    // Background music option
    @IBAction func settingFourAction(_ sender: Any) {
        if backgroundMusicOption {
            UserDefaults.standard.set(false, forKey: "backgroundMusicOn")
            settingFourButton.isSelected = false
            settingFourButton.setImage(#imageLiteral(resourceName: "customSwitchOff"), for: .normal)
        } else if !backgroundMusicOption {
            UserDefaults.standard.set(true, forKey: "backgroundMusicOn")
            settingFourButton.isSelected = true
            settingFourButton.setImage(#imageLiteral(resourceName: "customSwitchOn"), for: .selected)
        }
        backgroundMusicOption = UserDefaults.standard.bool(forKey: "backgroundMusicOn")
    }
    
    // Report a bug
    @IBAction func settingSevenAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailViewController = configureMailController()
            self.present(mailViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    Mail functions
    func configureMailController() -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        // Set fields
        mailVC.setToRecipients(["llamalaunching@gmail.com"])
        mailVC.setSubject("Report a bug")
        mailVC.setMessageBody("Please explain the bug in detail below. If you do not have a bug to report, you may also give some suggestions on improvements for the game, or any possible additions to the game that you would like to see in the future. \n --------------", isHTML: false)
        
        // Return
        return mailVC
    }
    
    func showMailError() {
        print("Mail services are not available")
        let alert = UIAlertController(title: "Setup an email account", message: "You must set up your email account in Settings > Accounts & Passwords to report a bug.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
}
