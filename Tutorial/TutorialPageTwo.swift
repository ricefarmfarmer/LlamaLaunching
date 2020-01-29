//
//  TutorialPageTwo.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/20/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit

class TutorialPageTwo: UIViewController {

    @IBOutlet weak var GifView: UIImageView!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GifView.loadGif(name: "tutorialGif2")
        
        styleLabel(label: labelOne, numberOfLines: 3)
        styleLabel(label: labelTwo, numberOfLines: 3)
        styleLabel(label: labelThree, numberOfLines: 1)
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
