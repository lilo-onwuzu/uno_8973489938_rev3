//
//  SelectTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SelectTableViewCell: UITableViewCell {

    var selectedListing = PFObject(className: "Listing")
    var myTableView = UITableView()
    var ready = false
    var viewController: SelectViewController!
    var userAccepted: PFUser!
    var emptyLabel = UILabel()
    var userSelected = Set<String>()
    
    @IBOutlet weak var userNameField: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var selectUserButton: UIButton!
    @IBOutlet weak var notifyLabel: UILabel!
    
    @objc func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
        let swipe = gestureRecognizer
        if swipe.state == .ended {
            switch swipe.direction {
            case UISwipeGestureRecognizerDirection.left:
                selectUserButton.isHidden = false
            default:
                return
            }
        }
    }
    
    func viewUserProfile() {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.objectUser = userAccepted
        viewController.present(vc, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 65
        selectUserButton.layer.masksToBounds = true
        selectUserButton.layer.cornerRadius = 15
        userNameField.layer.masksToBounds = true
        userNameField.layer.cornerRadius = 7
        userNameField.isHidden = true
        userImage.isHidden = true
        notifyLabel.isHidden = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            viewUserProfile()
            self.userNameField.textColor = UIColor.white
        } else {
            self.userNameField.textColor = #colorLiteral(red: 0.07987072319, green: 0.733002007, blue: 0.8219559789, alpha: 1)
            selectUserButton.isHidden = true
        }
    }
    
    @IBAction func selectUser(_ sender: Any) {
        var selected = selectedListing.object(forKey: "userSelected") as? [String] ?? []
        userSelected = NSSet(array: selected) as! Set<String>
        let maxCount = selectedListing.object(forKey: "objectCount") as! Int
        let count = userSelected.count
        let selectUser = userAccepted.objectId!
        if count < maxCount {
            if !userSelected.contains(selectUser) {
                userSelected.insert(selectUser)
                selected = Array(userSelected)
                selectedListing["userSelected"] = selected
                selectedListing.saveInBackground()
                notifyLabel.isHidden = false
            } else {
                emptyLabel.text = "YOU HAVE ALREADY SELECTED THIS PERSON"
            }
        } else {
            emptyLabel.text = "YOU HAVE SELECTED THE MAXIMUM AMOUNT OF PERSONS FOR THIS LISTING"
        }
    }
    
}
