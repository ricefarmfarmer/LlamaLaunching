//
//  EquipCollectionViewCell.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/15/19.
//  Copyright © 2019 Branden Yang. All rights reserved.
//

import UIKit

class EquipCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemStatus: UILabel!
    
    override var isSelected: Bool {
        didSet(selected) {
            if selected {

                self.isUserInteractionEnabled = false
                self.alpha = 0.7
                self.itemStatus.text = "Equipped"
            } else if !selected {
                self.isUserInteractionEnabled = true
                self.alpha = 1.0
                self.itemStatus.text = "Purchased"
            }
        }
    }
    
}
