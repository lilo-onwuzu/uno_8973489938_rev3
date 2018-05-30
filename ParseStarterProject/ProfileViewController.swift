//
//  ProfileViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import ImagePicker

class ProfileViewController: CommonSourceController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImagePickerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var libButton: UIButton!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var userDetails: UITextView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    var showMenu = true
    let text_field_limit = 600
    let imagePicker = UIImagePickerController()
    let ImagePicker = ImagePickerController()
    let user = PFUser.current()!
    
    // saves new story for user
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
    
    func showPhotoBar() {
        if (libButton.isHidden || camButton.isHidden) {
            // slide scrollview down to display photo editing bar
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.scrollView.center.y += 150
                self.camButton.isHidden = false
                self.libButton.isHidden = false
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.scrollView.center.y -= 150
                self.camButton.isHidden = true
                self.libButton.isHidden = true
            }, completion: nil)
        }
    }
    
    func saveImage(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        let imageFile = PFFile(data: imageData)!
        var images : [PFFile] = user["images"] as? [PFFile] ?? []
        images.append(imageFile)
        user["images"] = images
        user["image"] = images[images.startIndex]
        userImage.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeButton.layer.masksToBounds = true
        changeButton.layer.cornerRadius = 10
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 10
        imagePicker.delegate = self
        ImagePicker.delegate = self
        ImagePicker.imageLimit = 3
        
//        editStory.delegate = self
//        let firstName = user.object(forKey: "first_name") as! String
//        let lastName = user.object(forKey: "last_name") as! String
//        userName.text = firstName + " " + lastName
        
        // if story already exists for user, convert it to string (if possible- no "!" in typecast) and display it
//        if let story = user.object(forKey: "story") {
//            userStory.text = String(describing: story)
//            userStory.sizeToFit()
//
//        }
        
       // display user's saved image. user image data always exists in Parse
        if let imageFile = user.object(forKey: "image") as? PFFile {
            imageFile.getDataInBackground { (data, error) in
                if let data = data {
                    let imageData = NSData(data: data)
                    self.userImage.image = UIImage(data: imageData as Data)
                }
            }
        }
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
    
    // add inset below to allow tect field to be visible during editing
//    @IBAction func beginEdit(_ sender: Any) {
//        scrollView.contentInset.bottom += CGFloat(300)
//
//        // populate entry field with already stored story before editing
//        if let story = user.object(forKey: "story") {
////            editStory.text = String(describing: story)
////        }
//    }
//
//    @IBAction func endEditing(_ sender: Any) {
//        // remove inset once editing ends
//        scrollView.contentInset.bottom -= CGFloat(300)
//    }
//
//    // edit action executes "after editing ends" or return button is tapped
//    @IBAction func edit(_ sender: AnyObject) {
//        runEdit()
//
//    }
    
    @IBAction func home(_ sender: Any) {
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
        print("OH YEA WRAPPER DID")
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
        
    }

    // tap anywhere to escape keyboard. showMenu prevents the need for a double tap before menuView can be displayed again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
