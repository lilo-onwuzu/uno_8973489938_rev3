//
//  LoginViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class LoginViewController: CommonSourceController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func logInAction() {
        // do not accept empty login parameters
        if username.text != "" {
            if password.text != "" {
                activityIndicator = super.showActivity()
                let username_decap = username.text!.lowercased()
                // log in with Parse
                PFUser.logInWithUsername(inBackground: username_decap, password: password.text!, block: { (user, error) in
                    super.restore(activityIndicator: self.activityIndicator)
                    // show error alerts only after restore() function to allow interactivity
                    if let error = error?.localizedDescription {
                        super.alertWithSingleOption(title: "Failed Log In", message: error)
                    } else {
                        self.performSegue(withIdentifier: "toHome", sender: self)
                    }
                })
            } else {
                super.alertWithSingleOption(title: "Invalid Password", message: "Enter a valid password")
            }
        } else {
            super.alertWithSingleOption(title: "Invalid Email", message: "Enter the email address associated with your Facebook or Google accounts")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.delegate = self
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 10
    }
    
    @IBAction func login(_ sender: AnyObject) {
        logInAction()
    }
    
    // dismiss current VC to go back instead of using segue to go back. Segue creates a new instance or reference of the VC which could cause controller build up and your app to run of memory when excessively used.
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // tap anywhere on the screen to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // hit return to escape keyboard and login simultaneously
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logInAction()
        return true
    }
    
}
