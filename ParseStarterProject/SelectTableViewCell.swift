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
    var userAccepted: PFObject!
    
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
        vc.user = userAccepted
        viewController.present(vc, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 45
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
//            if self.isEqual(viewController.wasSelected) {
                viewUserProfile()
//            }
            self.userNameField.textColor = UIColor.white
//            viewController.wasSelected = self
        } else {
            self.userNameField.textColor = #colorLiteral(red: 0.07987072319, green: 0.733002007, blue: 0.8219559789, alpha: 1)
            selectUserButton.isHidden = true
        }
    }

}
