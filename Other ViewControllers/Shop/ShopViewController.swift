//
//  ShopViewController.swift
//  Llama Launching
//
//  Created by Branden Yang on 7/8/19.
//  Copyright © 2019 Branden Yang. All rights reserved.
//

import UIKit
import GameKit
import StoreKit
import SwiftyStoreKit


class ShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shopCollectionView: UICollectionView!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    
    var sharedSecret = "5b5cc351c52940f0b539766234d1e002"
    
    // Arrays for items displayed (Update these when adding new characters)
    let shopItems = ["Remove Ads", "Green Llama", "Purple Llama", "Blue Llama", "Red Llama", "Orange Llama", "Yellow Llama", "Pizza", "Baby Llama", "Restore Purchases"]
    let shopImages = [
        UIImage(named: "noAds"),
        UIImage(named: "greenLlama"),
        UIImage(named: "purpleLlama"),
        UIImage(named: "blueLlama"),
        UIImage(named: "redLlama"),
        UIImage(named: "orangeLlama"),
        UIImage(named: "yellowLlama"),
        UIImage(named: "pizza"),
        UIImage(named: "babyLlama"),
        UIImage(named: "cog")
    ]
    var shopPriceTags = ["$0.99 USD", "100 coins", "100 coins", "100 coins", "100 coins", "100 coins", "100 coins", "500 coins", "500 coins", "(Free)"]
    let shopPrices = [0, 100, 100, 100, 100, 100, 100, 500, 500, 0]
    let inAppPurchaseIDs = ["com.BrandenYang.LlamaLaunching.RemoveAds"]
    let purchaseUserDefaults = ["removeAdsPurchased", "greenLlamaPurchased", "purpleLlamaPurchased", "blueLlamaPurchased", "redLlamaPurchased", "orangeLlamaPurchased", "yellowLlamaPurchased", "pizzaPurchased", "babyLlamaPurchased"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopCollectionView.delegate = self
        shopCollectionView.dataSource = self
        
        let layout = self.shopCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.view.frame.width - 20) / 2, height: self.view.frame.size.height / 3)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.titleLabel?.lineBreakMode = .byTruncatingTail
        backButton.titleLabel?.numberOfLines = 1
        
        // Define coin label
        coinLabel.font = UIFont(name: "VCR OSD Mono", size: 28)
        coinLabel.textColor = .white
        coinLabel.adjustsFontSizeToFitWidth = true
        coinLabel.baselineAdjustment = .alignCenters
        coinLabel.lineBreakMode = .byTruncatingTail
        coinLabel.numberOfLines = 1
        
        let coins = UserDefaults.standard.integer(forKey: "coins")
        coinLabel.text = "\(coins)"
        
        updatePurchasedItems()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "hideCoins")
    }
    
    // Initialization/Setup of CollectionViewCells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCollectionViewCell", for: indexPath) as! ShopCollectionViewCell
        
        cell.itemDescription.text = shopItems[indexPath.item]
        cell.itemImage.image = shopImages[indexPath.item]
        cell.itemPrice.text = shopPriceTags[indexPath.item]
        if cell.itemPrice.text == "Purchased" {
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.7
        }
        
        return cell
    }
    
    // Interaction with CollectionViewCells
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 { // Remove Ads
            print("Attempting to purchase Remove Ads")
            purchaseProduct(withId: inAppPurchaseIDs[0], userDefault: purchaseUserDefaults[0])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[0]))")
            
        } else if indexPath.item == 1 { // Green Llama
            print("Attempting to purchase Green Llama")
            purchaseInGameProduct(shopItem: shopItems[1], userDefault: purchaseUserDefaults[1], price: shopPrices[1])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[1]))")
            
        } else if indexPath.item == 2 { // Purple Llama
            print("Attempting to purchase Purple Llama")
            purchaseInGameProduct(shopItem: shopItems[2], userDefault: purchaseUserDefaults[2], price: shopPrices[2])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[2]))")
            
        } else if indexPath.item == 3 { // Blue Llama
            print("Attempting to purchase Blue Llama")
            purchaseInGameProduct(shopItem: shopItems[3], userDefault: purchaseUserDefaults[3], price: shopPrices[3])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[3]))")
            
        } else if indexPath.item == 4 { // Red Llama
            print("Attempting to purchase Red Llama")
            purchaseInGameProduct(shopItem: shopItems[4], userDefault: purchaseUserDefaults[4], price: shopPrices[4])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[4]))")
            
        } else if indexPath.item == 5 { // Orange Llama
            print("Attempting to purchase Orange Llama")
            purchaseInGameProduct(shopItem: shopItems[5], userDefault: purchaseUserDefaults[5], price: shopPrices[5])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[5]))")
            
        } else if indexPath.item == 6 { // Yellow Llama
            print("Attempting to purchase Yellow Llama")
            purchaseInGameProduct(shopItem: shopItems[6], userDefault: purchaseUserDefaults[6], price: shopPrices[6])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[6]))")
            
        } else if indexPath.item == 7 { // Pizza
            print("Attempting to purchase Pizza")
            purchaseInGameProduct(shopItem: shopItems[7], userDefault: purchaseUserDefaults[7], price: shopPrices[7])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[7]))")
            
        } else if indexPath.item == 8 { // Baby Llama
            print("Attempting to purchase Baby Llama")
            purchaseInGameProduct(shopItem: shopItems[8], userDefault: purchaseUserDefaults[8], price: shopPrices[8])
            print("Has been purchased: \(UserDefaults.standard.bool(forKey: purchaseUserDefaults[8]))")
            
        } else if indexPath.item == 9 { // Restore Purchases
            print("Attempting to Restore Purchases")
            restorePurchases()
        }
    }
    
    // Update the visual status of purchased shop items
    func updatePurchasedItems() {
        verifyPurchase(withProductId: inAppPurchaseIDs[0], userDefault: purchaseUserDefaults[0])
        
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[0]) == true {
            shopPriceTags[0] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[1]) == true {
            shopPriceTags[1] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[2]) == true {
            shopPriceTags[2] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[3]) == true {
            shopPriceTags[3] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[4]) == true {
            shopPriceTags[4] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[5]) == true {
            shopPriceTags[5] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[6]) == true {
            shopPriceTags[6] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[7]) == true {
            shopPriceTags[7] = "Purchased"
        }
        if UserDefaults.standard.bool(forKey: purchaseUserDefaults[8]) == true {
            shopPriceTags[8] = "Purchased"
        }
    }
    
    // Purchase product - when using actual money
    func purchaseProduct(withId productId: String, userDefault: String) {
        if UserDefaults.standard.bool(forKey: userDefault) == false { // User has not already purchased
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let product):
                        // fetch content from your server, then:
                        if product.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(product.transaction)
                        }
                        // When purchase is successful, updates UserDefaults for the purchase's functionality
                        UserDefaults.standard.set(true, forKey: userDefault)
                        print("Purchase Success: \(product.productId)")
                        
                        // Dismiss the shopVC (otherwise price tags don't update)
                        self.dismiss(animated: true, completion: nil)
                        UserDefaults.standard.set(false, forKey: "hideCoins")
                        
                        // Note: We do not need an alert after the purchase, since it already shows one
                    case .error(let error):
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        default: print((error as NSError).localizedDescription)
                        }
                    }
                }
            }
        }
        } else { // User has already purchased
            let alreadyPurchasedAlert = UIAlertController(title: "Already purchased", message: "You have already purchased this item.", preferredStyle: .alert)
            alreadyPurchasedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alreadyPurchasedAlert, animated: true, completion: nil)
        }
    }
    
    // Purchase in-game product - when using in-game currency
    func purchaseInGameProduct(shopItem: String, userDefault: String, price: Int) {
        var coins = UserDefaults.standard.integer(forKey: "coins")
        // Check to see that user has not already purchased the item
        if UserDefaults.standard.bool(forKey: userDefault) == false { // User has not already purchased
            // Check to see that user has enough coins
            if coins >= price { // User has enough coins
                // Display confirmation alert
                let canPurchaseAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to purchase \(shopItem)?", preferredStyle: .alert)
                canPurchaseAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                canPurchaseAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    // Update coins (both UserDefault and our label)
                    coins -= price
                    UserDefaults.standard.set(coins, forKey: "coins")
                    self.coinLabel.text = "\(coins)"
                    
                    // Update shop item UserDefault
                    UserDefaults.standard.set(true, forKey: userDefault)
                    
                    // Display an alert that dismisses the shopVC (otherwise price tags don't update)
                    let purchasedAlert = UIAlertController(title: "Purchased", message: "You have purchased \(shopItem). You can equip it in the 'Equip' menu, which can be found from the main screen.", preferredStyle: .alert)
                    purchasedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        // Dismiss the shopVC (otherwise price tags don't update)
                        self.dismiss(animated: true, completion: nil)
                        UserDefaults.standard.set(false, forKey: "hideCoins")
                    }))
                    self.present(purchasedAlert, animated: true, completion: nil)
                }))
                self.present(canPurchaseAlert, animated: true, completion: nil)
            } else { // User does not have enough coins
                let cannotPurchaseAlert = UIAlertController(title: "Not enough coins", message: "You do not have enough coins to complete this purchase.", preferredStyle: .alert)
                cannotPurchaseAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(cannotPurchaseAlert, animated: true, completion: nil)
            }
        } else {
            let alreadyPurchasedAlert = UIAlertController(title: "Already purchased", message: "You have already purchased this item.", preferredStyle: .alert)
            alreadyPurchasedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alreadyPurchasedAlert, animated: true, completion: nil)
        }
    }
    
    // Restore purchases - updates the local status of purchased items
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                
                // Display alert
                let alert = UIAlertController(title: "Restore Failed", message: "The attempt to restore your purchases failed. Please retry or contact support (Report a Bug).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                    // Dismiss the shopVC (otherwise price tags don't update)
                    self.dismiss(animated: true, completion: nil)
                    UserDefaults.standard.set(false, forKey: "hideCoins")
                }))
                self.present(alert, animated: true, completion: nil)
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                
                // Display alert
                let alert = UIAlertController(title: "Purchases Restored", message: "Your purchases have been restored.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
                    // Dismiss the shopVC (otherwise price tags don't update)
                    self.dismiss(animated: true, completion: nil)
                    UserDefaults.standard.set(false, forKey: "hideCoins")
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Nothing to Restore")
                
                // Display alert
                let alert = UIAlertController(title: "Nothing to Restore", message: "You have no purchases to restore.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Verify purchases - updates the UserDefaults of purchased items
    func verifyPurchase(withProductId id: String, userDefault: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = id
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("\(productId) is purchased: \(receiptItem)")
                    UserDefaults.standard.set(true, forKey: userDefault)
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
