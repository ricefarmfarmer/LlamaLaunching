//
//  TutorialMainViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/21/18.
//  Copyright © 2018 Branden Yang. All rights reserved.
//

import UIKit

class TutorialMainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0
        UIView.animate(withDuration: 1.0, animations: {
            self.view.alpha = 1
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialViewController = segue.destination as? TutorialViewController {
            tutorialViewController.tutorialDelegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension TutorialMainViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(tutorialPageViewController: TutorialViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: TutorialViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
