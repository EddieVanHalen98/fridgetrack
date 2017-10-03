//
//  NewFoodController.swift
//  fridgetrack
//
//  Created by James Saeed on 25/09/2017.
//  Copyright © 2017 evh98. All rights reserved.
//

import UIKit
import Firebase
import Eureka
import GoogleMobileAds
import UserNotifications

class NewFoodController: FormViewController {
    
    var ref: FIRDatabaseReference!
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child((FIRAuth.auth()?.currentUser?.uid)!)
        
        form +++ Section("Add Food")
            <<< TextRow() { row in
                row.title = "Name"
                row.placeholder = "What food would you like to add?"
                row.tag = "FoodName"
                row.add(rule: RuleRequired())
            }
            <<< IntRow() { row in
                row.title = "Quantity"
                row.placeholder = "How much of it do you have?"
                row.tag = "FoodQuantity"
                row.add(rule: RuleRequired())
            }
            <<< DateRow() { row in
                row.title = "Expiry Date"
                row.value = Date()
                row.tag = "FoodExpiry"
                row.add(rule: RuleRequired())
            }
        
            +++ Section(){ section in
                section.footer = {
                    var footer = HeaderFooterView<UIView>(.callback({
                        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
                        view.backgroundColor = .red
                        
                        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
                        // Test Unit: ca-app-pub-3940256099942544/6300978111
                        // Actual Unit: ca-app-pub-3031375681685379/2176336622
                        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
                        self.bannerView.rootViewController = self
                        self.bannerView.load(GADRequest())
                        
                        return self.bannerView
                    }))
                    footer.height = { 50 }
                    return footer
                }()
            }
    }
    
    @IBAction func save(_ sender: Any) {
        let parent = ref.childByAutoId()
        let row: TextRow? = form.rowBy(tag: "FoodName")
        let row2: IntRow? = form.rowBy(tag: "FoodQuantity")
        let row3: DateRow? = form.rowBy(tag: "FoodExpiry")
        
        let food = row!.value!.lowercased()
        let quantity = row2!.value
        
        var expiry = row3!.value?.description
        let index = expiry!.index(of: " ") ?? expiry!.endIndex
        expiry = String(expiry![..<index])
        
        let data: [String: Any] = ["food" : food as Any, "quantity": quantity as Any, "expiry": expiry as Any]
        
        parent.updateChildValues(data)
        
        self.navigationController?.popViewController(animated: true)
    }
}
