//
//  LoginController.swift
//  fridgetrack
//
//  Created by James Saeed on 16/09/2017.
//  Copyright © 2017 evh98. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "open", sender: nil)
            }
        }
    }
    
    
    @IBAction func emailDone(_ sender: Any) {
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func passwordDone(_ sender: Any) {
        passwordField.resignFirstResponder()
    }
    
    @IBAction func submit(_ sender: Any) {
        indicator.startAnimating()
        
        if let email = emailField.text, let password = passwordField.text { 
            // Log in
            FIRAuth.auth()!.signIn(withEmail: email, password: password) { (user, error) in
                if (user == nil) {
                    // Sign up if login fail
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        self.indicator.stopAnimating()
                        self.performSegue(withIdentifier: "open", sender: nil)
                    })
                } else {
                    self.indicator.stopAnimating()
                    self.performSegue(withIdentifier: "open", sender: nil)
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
