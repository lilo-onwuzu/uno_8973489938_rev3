//
//  SignUpViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import FacebookCore
import FacebookLogin

class SignUpViewController: CommonSourceController, LoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var createPassword2: UITextField!
    @IBOutlet weak var job: UITextField!
    @IBOutlet weak var moreInfo: UITextField!
    @IBOutlet weak var facebookIcon: UIButton!
    @IBOutlet weak var googleIcon: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    // initialize new empty PFUser object for new user
    var user: PFUser = PFUser()
    // initialize new boolean to verify successful login and facebook user detail collection
    var loggedIn: Bool = Bool()
    // initialize facebook login delegate button (permissions the delegate to get info in [] array
    let facebookButton = LoginButton(readPermissions: [ .publicProfile , .email , .userFriends ])
    
    func signUp() {
        self.activityIndicator = super.showActivity()
//         if self.loggedIn {
            self.user.signUpInBackground(block: { (success, error) in
                super.restore(activityIndicator: self.activityIndicator)
                if success {
                    super.alertWithSingleOption(title: "Successful!", message: "Thanks for signing up.")
                    self.performSegue(withIdentifier: "toLogin", sender: self)
                } else {
                    if let error = error?.localizedDescription {
                        // display sign up error message
                        super.alertWithSingleOption(title: "Failed Sign Up", message: error)
                    }
                }
            })
        //  } else {
        //      self.restore(activityIndicator)
        //      self.alertWithSingleOption(title: "Invalid Facebook Login", message: "You need to log in with Facebook to sign up with WorkJet")
        //  }
    }
    
    func dontSignUp() {
        super.alertWithSingleOption(title: "Agree to Terms of Use", message: "You must read and agree to the terms of use before signing up")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // assign textfield's delegate to view controller to allow view controller to control the password textfield
        // view controller as already been subclassed as a UITextFieldDelegate
        self.createPassword.delegate = self
        self.signUpButton.layer.masksToBounds = true
        self.signUpButton.layer.cornerRadius = 10
        
        // display Facebook login button and position rect to receive login button
        facebookButton.frame = CGRect(x: (self.view.bounds.width / 2) - 25, y: (self.view.bounds.height / 2) - 13, width: 50, height: 50)
        // facebookButton does not exist in MainStoryboard so add it to view
//        view.addSubview(facebookButton)
        // assign login button's delegate to view controller to allow view controller to log in to facebook
        // view controller as already been subclassed as a LoginButtonDelegate
        facebookButton.delegate = self
        
        // get new user's location 
        PFGeoPoint.geoPointForCurrentLocation { (coordinates, error) in
            if let coordinates = coordinates {
                self.user.setValue(coordinates, forKey: "location")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(presentingViewController)
        print(presentingViewController?.childViewControllers)
//        print(self.p )
    }
    
    // FBSDKLoginDelegate method
    // add facebook login details before sign up
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        activityIndicator = super.showActivity()
        let parameters = ["fields": "email, first_name, last_ "]

        // facebook graph request
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            // be careful with "let" statement. Only use them for certainly controllable events
            // when communicating with an external SDK, try to use the "if let" block where necessary so app does not crash if SDK changes and requests are unsuccessful
            // try ("as?") to cast the result of the graph request as a dictionary, if successful, continue with the product as a new variable "result", if that fails for any reason, result does not exist because it was never initialized, function terminates with no crash
            if let result = result as? NSDictionary {
                if let email = result.object(forKey: "email") as? String {
                    if let firstName = result.object(forKey: "first_name") as? String {
                        if let lastName = result.object(forKey: "last_name") as? String {
                            if let facebookId = result.object(forKey: "id") as? String {
//                                self.facebookButton.isHidden = true
//                                self.facebookIcon.isHidden = true
                                // add user attributes to PFUser object first
                                self.user.username = email
                                self.user.email = email
                                self.user["first_name"] = firstName
                                self.user["last_name"] = lastName
                                self.user["facebookId"] = facebookId
                                // display welcome message and restore app interactivity
//                                self.name.text = "Welcome, " + firstName + " " + lastName + "!"
                                // once user has logged in and details collected, set Boolean to true
                                self.loggedIn = true
                                // import FB photo if possible
                                let url = "https://graph.facebook.com/" + facebookId + "/picture?type=large"
                                let imageUrl = NSURL(string: url)!
                                // try to make imageData object  but do not force cast with "!". The result is an optional NSData object. It will be ignored it unsuccessful
                                let imageData = NSData(contentsOf: imageUrl as URL)
                                // use "if let" conditional to prevent crash if imageData object is not successully cast. The result of the  "if let" conditional below is "imageData": a non-optional NSData object
                                if let imageData = imageData {
                                    let imageFile: PFFile = PFFile(data: imageData as Data)!
                                    self.user["image"] = imageFile
                                    
                                }
                                
                                // get user's friends list
                                FBSDKGraphRequest(graphPath:"me/friends", parameters: nil).start(completionHandler: { (connection, list, error) in
                                    if let list = list as? NSDictionary {
                                        if let friends = list.object(forKey: "data") as? [NSDictionary] {
                                            var arr = [String]()
                                            for friend in friends {
                                                let str = friend.object(forKey: "id") as! String
                                                arr.append(str)
                                            
                                            }
                                            // add to PFUser object
                                            self.user.setValue(arr, forKey: "fb_friends")

                                        }
                                    }
                                })
                                
                            }
                        }
                    }
                }
            }
        }
        super.restore(activityIndicator: self.activityIndicator)
    }
    
    // FBSDKLoginDelegate method. Not needed, login button is hidden after successful login activity
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        let pass1 = self.createPassword.text
        let pass2 = self.createPassword2.text
        if pass1 != "" || pass2 != "" {
            if pass1 == pass2 {
                self.user.password = pass1
                // agree to terms of use
                var actions = [String: String]()
                actions["Yes, I agree"] = "signUp"
                actions["No, I do not agree"] = "dontSignUp"
                super.alertWithMultipleOptions(title: "Terms of Use", message: "You may not post content that is violent, discriminatory, abusive, illegal or sexually explicit. Uno retains the right to delete a violating user account or at a minimum the violating content itself", options: actions)
            } else {
                super.alertWithSingleOption(title: "Password Mismatch", message: "The passwords you entered do not match")
            }
        } else {
             super.alertWithSingleOption(title: "Invalid Password", message: "Please enter a valid password")
        }
    }
  
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
