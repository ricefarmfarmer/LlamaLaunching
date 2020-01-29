//
//  EquipViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/15/19.
//  Copyright © 2019 Branden Yang. All rights reserved.
//

import UIKit

class EquipViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var equipCollectionView: UICollectionView!
    
    // These are the 'all' arrays (Update these when adding new characters)
    let allEquipItems = ["Green Llama", "Purple Llama", "Blue Llama", "Red Llama", "Orange Llama", "Yellow Llama", "Pizza", "Baby Llama"]
    let allEquipItemImages = [
        UIImage(named: "greenLlama"),
        UIImage(named: "purpleLlama"),
        UIImage(named: "blueLlama"),
        UIImage(named: "redLlama"),
        UIImage(named: "orangeLlama"),
        UIImage(named: "yellowLlama"),
        UIImage(named: "pizza"),
        UIImage(named: "babyLlama")
    ]
    let allEquipItemStatuses = ["Purchased", "Purchased", "Purchased", "Purchased", "Purchased", "Purchased", "Purchased", "Purchased"]
    
    // These are the 'owned' arrays
    var ownedEquipItems = ["Llama"]
    var ownedEquipItemImages = [UIImage(named: "llama")]
    var ownedEquipItemStatuses = ["Equipped"]
    
    var playerTextureName = "llama"
    let purchaseUserDefaults = ["greenLlamaPurchased", "purpleLlamaPurchased", "blueLlamaPurchased", "redLlamaPurchased", "orangeLlamaPurchased", "yellowLlamaPurchased", "pizzaPurchased", "babyLlamaPurchased"]
    let characterUserDefaults = ["greenLlama", "purpleLlama", "blueLlama", "redLlama", "orangeLlama", "yellowLlama", "pizza", "babyLlama"]
    var itemCount : Int = 1 // Starts off at 1 because of the normal llama
    
    override func viewDidLoad() {
        super.viewDidLoad()
        equipCollectionView.delegate = self
        equipCollectionView.dataSource = self

        let layout = self.equipCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.view.frame.width - 20) / 2, height: self.view.frame.size.height / 3)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.titleLabel?.lineBreakMode = .byTruncatingTail
        backButton.titleLabel?.numberOfLines = 1
        
        equipCollectionView.allowsMultipleSelection = false
        updateAvailableItems()
        updateEquippedItem()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "hideCoins")
    }
    
    // Initialization/Setup of CollectionViewCells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return ownedEquipItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Use a guard in case the cell type is different: https://stackoverflow.com/questions/40940014/why-will-diddeselectitemat-of-uicollectionview-throw-an-error-of-unexpected-foun
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EquipCollectionViewCell", for: indexPath) as? EquipCollectionViewCell else {
            fatalError("Wrong cell type")
        }
        
        cell.itemDescription.text = ownedEquipItems[indexPath.item]
        cell.itemImage.image = ownedEquipItemImages[indexPath.item]
        cell.itemStatus.text = ownedEquipItemStatuses[indexPath.item]
        if cell.itemStatus.text == "Equipped" {
            cell.isSelected = true
            cell.itemStatus.text = "Equipped" // NEED THIS BECAUSE ITS VERY FINNICKY DON'T ASK WHY
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.7
        }
        
        return cell
    }
    
    // Interaction with CollectionViewCells
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        let cell = collectionView.cellForItem(at: indexPath) as! EquipCollectionViewCell
        
        if cell.itemDescription.text == ownedEquipItems[0] {
            // Set the UserDefault
            UserDefaults.standard.set("llama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[0] {
            // Set the UserDefault
            UserDefaults.standard.set("greenLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[1] {
            // Set the UserDefault
            UserDefaults.standard.set("purpleLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[2] {
            // Set the UserDefault
            UserDefaults.standard.set("blueLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[3] {
            // Set the UserDefault
            UserDefaults.standard.set("redLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[4] {
            // Set the UserDefault
            UserDefaults.standard.set("orangeLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[5] {
            // Set the UserDefault
            UserDefaults.standard.set("yellowLlama", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[6] {
            // Set the UserDefault
            UserDefaults.standard.set("pizza", forKey: "playerTexture")

        } else if cell.itemDescription.text == allEquipItems[7] {
            // Set the UserDefault
            UserDefaults.standard.set("babyLlama", forKey: "playerTexture")

        }
        
        cell.isUserInteractionEnabled = false
        cell.alpha = 0.7
        cell.itemStatus.text = "Equipped"
        
        // We're just dismissing the view - i've tried it other ways and its just way too finnicky for my tastes
        self.dismiss(animated: true, completion: nil)
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        // If the cell is out of view, then we just ignore and move on (we're dismissing the view so it doesn't matter, i've tried it other ways before and its just way too finnicky for my tastes, so we'll just dismiss the view)
//        guard let cell = collectionView.cellForItem(at: indexPath) as? EquipCollectionViewCell else {
//            return
//        }
//
//        cell.isUserInteractionEnabled = true
//        cell.alpha = 1.0
//        cell.itemStatus.text = "Purchased"
//    }
    
    // Updates the 'owned' arrays (the purchased items) based on the value of the UserDefaults
    func updateAvailableItems() {
        // We add from the 'all' arrays into the 'owned' arrays
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[0]) == true {
            ownedEquipItems.append(allEquipItems[0])
            ownedEquipItemImages.append(allEquipItemImages[0])
            ownedEquipItemStatuses.append(allEquipItemStatuses[0])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[1]) == true {
            ownedEquipItems.append(allEquipItems[1])
            ownedEquipItemImages.append(allEquipItemImages[1])
            ownedEquipItemStatuses.append(allEquipItemStatuses[1])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[2]) == true {
            ownedEquipItems.append(allEquipItems[2])
            ownedEquipItemImages.append(allEquipItemImages[2])
            ownedEquipItemStatuses.append(allEquipItemStatuses[2])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[3]) == true {
            ownedEquipItems.append(allEquipItems[3])
            ownedEquipItemImages.append(allEquipItemImages[3])
            ownedEquipItemStatuses.append(allEquipItemStatuses[3])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[4]) == true {
            ownedEquipItems.append(allEquipItems[4])
            ownedEquipItemImages.append(allEquipItemImages[4])
            ownedEquipItemStatuses.append(allEquipItemStatuses[4])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[5]) == true {
            ownedEquipItems.append(allEquipItems[5])
            ownedEquipItemImages.append(allEquipItemImages[5])
            ownedEquipItemStatuses.append(allEquipItemStatuses[5])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[6]) == true {
            ownedEquipItems.append(allEquipItems[6])
            ownedEquipItemImages.append(allEquipItemImages[6])
            ownedEquipItemStatuses.append(allEquipItemStatuses[6])
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[7]) == true {
            ownedEquipItems.append(allEquipItems[7])
            ownedEquipItemImages.append(allEquipItemImages[7])
            ownedEquipItemStatuses.append(allEquipItemStatuses[7])
        }
    }
    
    // Updates visual status of the equipped item ON THE INITIAL LOAD - checks if item is purchased then if it's the current playerTexture
    func updateEquippedItem() {
        // We need to get the total number of purchased items so that we can properly set the labels - otherwise there's a mess up with trying to set at a specific array index
        var purchasedItems = 0
        for userDefault in purchaseUserDefaults {
            if UserDefaults.standard.bool(forKey: userDefault) == true {
                purchasedItems += 1
            }
        }
        
        // The 'owned' arrays start off w/ an initial value so its always gonna be ok to just replace the 0 index
        if UserDefaults.standard.string(forKey: "playerTexture") == "llama" {
            ownedEquipItemStatuses[0] = "Equipped"
        } else {
            ownedEquipItemStatuses[0] = "Purchased"
        }
        
        // Check if the user has purchased the character
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[0]) == true {
            // Check if the user has the character already equipped
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[0] {
                if 1 <= purchasedItems {
                    // If the array value is okay to replace at that index, then we replace it directly
                    ownedEquipItemStatuses[1] = "Equipped"
                } else {
                    // If the array index is out of bounds, then we use the purchasedItems as the index
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 1 <= purchasedItems {
                    // If the array value is okay to replace at that index, then we replace it directly
                    ownedEquipItemStatuses[1] = "Purchased"
                } else {
                    // If the array index is out of bounds, then we use the purchasedItems as the index
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[1]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[1] {
                if 2 <= purchasedItems {
                    ownedEquipItemStatuses[2] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 2 <= purchasedItems {
                    ownedEquipItemStatuses[2] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[2]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[2] {
                if 3 <= purchasedItems {
                    ownedEquipItemStatuses[3] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 3 <= purchasedItems {
                    ownedEquipItemStatuses[3] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[3]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[3] {
                if 4 <= purchasedItems {
                    ownedEquipItemStatuses[4] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 4 <= purchasedItems {
                    ownedEquipItemStatuses[4] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[4]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[4] {
                if 5 <= purchasedItems {
                    ownedEquipItemStatuses[5] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 5 <= purchasedItems {
                    ownedEquipItemStatuses[5] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[5]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[5] {
                if 6 <= purchasedItems {
                    ownedEquipItemStatuses[6] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 6 <= purchasedItems {
                    ownedEquipItemStatuses[6] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[6]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[6] {
                if 7 <= purchasedItems {
                    ownedEquipItemStatuses[7] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 7 <= purchasedItems {
                    ownedEquipItemStatuses[7] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[7]) == true {
            if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[7] {
                if 8 <= purchasedItems {
                    ownedEquipItemStatuses[8] = "Equipped"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Equipped"
                }
            } else {
                if 8 <= purchasedItems {
                    ownedEquipItemStatuses[8] = "Purchased"
                } else {
                    ownedEquipItemStatuses[purchasedItems] = "Purchased"
                }
            }
        }
        
        // FOR-LOOP VERSION (ITS SUPER TACKY AND I HAVE NO IDEA IF IT WORKS LOL, ILL JUST KEEP IT HERE IN CASE YOU CHANGE YOUR MIND)
//        var index = 0
//        for userDefault in purchaseUserDefaults {
//            if UserDefaults.standard.bool(forKey: userDefault) == true {
//                if UserDefaults.standard.string(forKey: "playerTexture") == characterUserDefaults[index] {
//                    ownedEquipItemStatuses[index + 1] = "Equipped"
//                } else {
//                    ownedEquipItemStatuses[index + 1] = "Purchased"
//                }
//            }
//            index += 1
//        }
    }
}
