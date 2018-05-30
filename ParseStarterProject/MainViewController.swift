//
//  ViewController.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class MainViewController: CommonSourceController {
    
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var appLabel2: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 10
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let user = PFUser.current()!
        if user.isAuthenticated && user.email != nil {
            // if user is signed in. direct to home
            performSegue(withIdentifier: "skipToHome", sender: self)
        } else {
            performSegue(withIdentifier: "toLogin", sender: self)
        }
    }

}

