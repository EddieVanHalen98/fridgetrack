//
//  HomeController.swift
//  fridgetrack
//
//  Created by James Saeed on 19/09/2017.
//  Copyright © 2017 evh98. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class HomeController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var ref: FIRDatabaseReference!
    
    var foods = [Food]()
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge],
                                                                completionHandler: {didAllow, error in })
        
        indicator.startAnimating()
        
        ref = FIRDatabase.database().reference().child((FIRAuth.auth()?.currentUser?.uid)!)
        
        loadFood()
        
        if (collectionView.numberOfItems(inSection: 0)) == 0 {
            indicator.stopAnimating()
        }
    }
    
    private func loadFood() {
        ref.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! [String : AnyObject]
            
            let id = snapshot.ref.key
            let name = value["food"] as? String ?? ""
            let quantity = value["quantity"] as? Int ?? 0
            let expiryDate = value["expiry"] as? String ?? ""
            
            let food = Food(id: id, name: name, quantity: quantity, expiryDate: expiryDate)
            
            self.foods.append(food)
            self.collectionView.insertItems(at: [IndexPath(row: self.foods.count - 1, section: 0)])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        
        let food = foods[indexPath.item]
        
        food.expiryDays = calculateExpiryDays(expiryDate: food.expiryDate!)
        
        cell.name.text = food.name
        cell.info.text = "\(String(describing: food.quantity!)) left and expire in \(String(describing: food.expiryDays!)) days"
        
        if food.expiryDays! <= 0 {
            cell.background.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
            cell.info.text = "Expired"
        }
        if food.expiryDays! > 0 && food.expiryDays! < 3 {
            cell.background.backgroundColor = UIColor(red: 0.94, green: 0.33, blue: 0.31, alpha: 1.0)
        } else if food.expiryDays! > 2 && food.expiryDays! < 7 {
            cell.background.backgroundColor = UIColor(red: 1.00, green: 0.65, blue: 0.15, alpha: 1.0)
        } else if food.expiryDays! > 6 && food.expiryDays! < 10 {
            cell.background.backgroundColor = UIColor(red: 0.61, green: 0.80, blue: 0.40, alpha: 1.0)
        } else {
            cell.background.backgroundColor = UIColor(red:0.40, green:0.73, blue:0.42, alpha:1.0)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        UIView.animate(withDuration: 0.5) {
            cell?.contentView.transform = CGAffineTransform(scaleX: 0.55, y: 0.55)
        }
        
        UIView.animate(withDuration: 0.5) {
            cell?.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if foods[indexPath.item].quantity! == 1 || foods[indexPath.item].expiryDays! < 0 {
            removeFood(index: indexPath.item)
        } else {
            decreaseFood(index: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0)
        
        if indexPath.row == lastRowIndex - 1 || lastRowIndex == 0 {
            indicator.stopAnimating()
        }
    }
    
    private func removeFood(index: Int) {
        ref.child(foods[index].id!).removeValue()
        foods.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        
        self.collectionView.reloadData()
    }
    
    private func decreaseFood(index: Int) {
        let newQuantity = foods[index].quantity! - 1
        
        ref.child(foods[index].id!).updateChildValues(["quantity": newQuantity])
        foods[index].quantity! = newQuantity
        self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    @IBAction func showOptions(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action: UIAlertAction) in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func logout() {
        do {
            try FIRAuth.auth()!.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.performSegue(withIdentifier: "logout", sender: nil)
    }
    
    private func calculateExpiryDays(expiryDate: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let expiryDateFormat = dateFormatter.date(from: expiryDate)
        return expiryDateFormat!.days(from: Date()) + 1
    }
}

extension Date {
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}
