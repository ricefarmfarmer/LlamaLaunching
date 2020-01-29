//
//  TutorialPageOne.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/20/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit

class TutorialPageOne: UIViewController {

    @IBOutlet weak var GifView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GifView.loadGif(name: "tutorialGif1")
        
        styleLabel(label: topLabel, numberOfLines: 2)
        styleLabel(label: labelOne, numberOfLines: 2)
        styleLabel(label: labelTwo, numberOfLines: 1)
        styleLabel(label: labelThree, numberOfLines: 1)
        styleLabel(label: labelFour, numberOfLines: 1)
    }
    
    func styleLabel(label: UILabel, numberOfLines: Int) {
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byClipping
        label.numberOfLines = numberOfLines
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
