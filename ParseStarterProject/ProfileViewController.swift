//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import ImagePicker

class ProfileViewController: CommonSourceController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImagePickerDelegate {
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var libButton: UIButton!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var userDetails: UITextView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameField: UILabel!
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var passwordUpdatedLabel: UILabel!
    
    let text_field_limit = 600
    let imagePicker = UIImagePickerController()
    let ImagePicker = ImagePickerController()
    var subjectUser: PFUser!
    var objectUser: PFUser!
    var user: PFUser!
    var userId = ""
    var activityIndicator = UIActivityIndicatorView()
    var editMode = false
    
    func runEdit() {
//        let editStory = self.editStory.text!
//        // update displayed user story
//        userStory.text = editStory
//        // update user story in Parse
//        user["story"] = editStory
//        // save to Parse
//        user.saveInBackground(block: { (success, error) in
//            if let error = error?.localizedDescription {
//                self.alertWithSingleOption(title: "Database Error", message: error)
//            } else {
//                self.editStory.text = "Your story has been updated!"
//                self.userStory.sizeToFit()
//            }
//        })
    }
    
    func setHomeButton() {
        if (!editMode) {
            homeButton.setTitle("<", for: .normal)
            homeButton.setImage(nil, for: .normal)
            homeButton.setTitleColor(#colorLiteral(red: 0.07987072319, green: 0.733002007, blue: 0.8219559789, alpha: 1), for: .normal)
        }
    }
    
    func showPhotoBar() {
        if (libButton.isHidden || camButton.isHidden) {
            // slide scrollview down to display photo editing bar
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.camButton.isHidden = false
                self.libButton.isHidden = false
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.camButton.isHidden = true
                self.libButton.isHidden = true
            }, completion: nil)
        }
    }
    
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        let imageFile = PFFile(data: imageData)!
        user["image"] = imageFile
        userImage.image = image
    }
    
    @objc func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        let swipe = gestureRecognizer
        switch swipe.direction {
            case UISwipeGestureRecognizerDirection.up:
                if objectUser.isEqual(subjectUser) && editMode {
                    removeImageMode()
                }
            case UISwipeGestureRecognizerDirection.down:
                if objectUser.isEqual(subjectUser) && editMode {
                    displayImageMode()
                }
            default:
                return;
        }
    }
    
    func displayImageMode() {
        userImage.isHidden = false
        userNameField.isHidden = false
        userDetails.isHidden = true
        password.isHidden = true
        confirmPassword.isHidden = true
        changeButton.isHidden = true
        deleteButton.isHidden = true
        editDetailsButton.isHidden = true
    }

    func removeImageMode() {
        userImage.isHidden = true
        userNameField.isHidden = true
        userDetails.isHidden = false
        password.isHidden = false
        confirmPassword.isHidden = false
        changeButton.isHidden = false
        deleteButton.isHidden = false
        editDetailsButton.isHidden = false
    }
    
    @objc func savePassword() {
        user.password = self.password.text!
        user.saveInBackground { (success, error) in
            if success {
                self.passwordUpdatedLabel.text = "Your password has been updated!"
                self.passwordUpdatedLabel.isHidden = false
            } else {
                if let error = error {
                    super.alertWithSingleOption(title: "Update Password Error", message: error.localizedDescription)
                }
            }
            // reset password field
            self.password.text = ""
            self.confirmPassword.text = ""
            self.view.endEditing(true)
        }
    }
    
    func finallyDeleteUser() {
        self.user.deleteInBackground(block: { (success, error) in
            if success {
                PFUser.logOut()
                self.performSegue(withIdentifier: "toHome", sender: self)
            }
        })
        super.restore(activityIndicator: activityIndicator)
    }
    
    func deleteAsAccepted () {
        // remove userId from every listing's array of acceptedUsers
        let queryAccepted = PFQuery(className: "Listing")
        queryAccepted.whereKey("userAccepted", contains: userId)
        queryAccepted.findObjectsInBackground { (listings, error) in
            if let listings = listings {
                if listings.count > 0 {
                    for listing in listings {
                        var userAccepted = listing.object(forKey: "userAccepted") as! [String]
                        for id in userAccepted {
                            if id == self.userId {
                                userAccepted.remove(at: userAccepted.index(of: id)!)
                                listing.setValue(userAccepted, forKey: "userAccepted")
                                listing.saveInBackground()
                            }
                        }
                    }
                }
            }
        }
        finallyDeleteUser()
    }
    
    func deleteAsSelected () {
        // then delete user as selectedUser for all jobs
        let querySelected = PFQuery(className: "Listing")
        querySelected.whereKey("selectedUser", equalTo: userId)
        querySelected.findObjectsInBackground { (listings, error) in
            if let listings = listings {
                if listings.count > 0 {
                    for listing in listings {
                        // empty selected user
                        listing.setValue("", forKey: "selectedUser")
                        listing.saveInBackground()
                    }
                }
            }
        }
        deleteAsAccepted()
    }
    
    func deleteUser() {
        // first delete all user's posted jobs
        let queryPosted = PFQuery(className: "Listing")
        queryPosted.whereKey("requesterId", equalTo: userId)
        queryPosted.findObjectsInBackground { (listings, error) in
            if let listings = listings {
                if listings.count > 0 {
                    for listing in listings {
                        listing.deleteInBackground()
                    }
                }
            }
        }
        deleteAsSelected()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeButton.layer.masksToBounds = true
        changeButton.layer.cornerRadius = 10
        editDetailsButton.layer.masksToBounds = true
        editDetailsButton.layer.cornerRadius = 10
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 10
        userDetails.layer.masksToBounds = true
        userDetails.layer.cornerRadius = 10
        imagePicker.delegate = self
        ImagePicker.delegate = self
        ImagePicker.imageLimit = 3
        userDetails.delegate = self
        libButton.layer.masksToBounds = true
        libButton.layer.cornerRadius = 10
        camButton.layer.masksToBounds = true
        camButton.layer.cornerRadius = 10
        displayImageMode()
        if objectUser.isEqual(subjectUser) && !editMode {
            user = subjectUser
            editMode = true
        } else {
            user = objectUser
            editMode = false
            setHomeButton()
        }
        userId = user.objectId!
        let firstName = user.object(forKey: "first_name") as! String
        let lastName = user.object(forKey: "last_name") as! String
        userNameField.text = firstName + " " + lastName
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gestureRecognizer:)))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gestureRecognizer:)))
        swipeDown.direction = .down
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        // if story already exists for user, convert it to string (if possible- no "!" in typecast) and display it
        if let story = user.object(forKey: "story") {
            userDetails.text = String(describing: story)
            userDetails.sizeToFit()
        }
       // display user's saved image
        if let imageFile = user.object(forKey: "image") as? PFFile {
            imageFile.getDataInBackground { (data, error) in
                if let data = data {
                    let imageData = NSData(data: data)
                    self.userImage.image = UIImage(data: imageData as Data)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.hideMenu(mainView: self.view)
    }
    
    @IBAction func changePhoto(_ sender: Any) {
        showPhotoBar()
    }

    @IBAction func photos(_ sender: Any) {
        self.present(ImagePicker, animated: true, completion: nil)
    }

    @IBAction func camera(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        if password.isHidden {
            editDetailsButton.isHidden = true
            deleteButton.isHidden = true
            password.isHidden = false
            confirmPassword.isHidden = false
        } else {
            let getPassword = self.password.text!
            let confirmPassword = self.confirmPassword.text!
            var actions = [String: String]()
            actions["Yes"] = "savePassword"
            actions["Cancel"] = ""
            // password character length must be greater than 5
            if getPassword.count >= 6 {
                if getPassword == confirmPassword {
                    super.alertWithMultipleOptions(title: "Confirm Password Change", message: "Are you sure you want to change your password?", options: actions)
                } else {
                    super.alertWithSingleOption(title: "Invalid Password", message: "Your passwords must match")
                }
            } else {
                super.alertWithSingleOption(title: "Invalid Password", message: "Your password must have at least 6 characters")
            }
        }
    }
    
    @IBAction func editDetails(_ sender: Any) {
        changeButton.isHidden = true
        deleteButton.isHidden = true
        userDetails.isHidden = false
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        activityIndicator = super.showActivity()
        deleteUser()
    }
    
    @IBAction func home(_ sender: Any) {
        if (!editMode) {
            dismiss(animated: true, completion: nil)
            return
        }
        super.showMenu(mainView: self.view)
    }
    
    // run after UIImagePickerController has succesfully gotten a selected image, updates Parse with new image and changes displayed image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            saveImage(image: pickedImage)
        }
        // dismiss imagePicker controller
        self.dismiss(animated: true, completion: nil)
        showPhotoBar()
        user.saveInBackground()
    }
    
    // protocol for custom module ImagePickerDelegate (library only)
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    // protocol for custom module ImagePickerDelegate (library only)
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images {
            saveImage(image : image)
        }
        // dismiss imagePicker controller
        self.dismiss(animated: true, completion: nil)
        showPhotoBar()
        user.saveInBackground()
    }
    
    // protocol for custom module ImagePickerDelegate (library only)
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    // tap anywhere to escape keyboard and/or menu
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.hideMenu(mainView: self.view)
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runEdit()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= text_field_limit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
