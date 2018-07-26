//
//  PostedTableViewCell.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedTableViewCell: UITableViewCell {
    
    var myTableView = UITableView()
    var ready = false
    var viewController: PostedViewController!
    var postedListing = PFObject(className: "Listing")
    var listingImages = [PFFile]()
    
    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var likedButton: UIButton!
    
    func hideButtons() {
        editButton.isHidden = true
        deleteButton.isHidden = true
        likedButton.isHidden = true
    }
    
    @objc func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
        let swipe = gestureRecognizer
        if swipe.state == .ended {
            switch swipe.direction {
                case UISwipeGestureRecognizerDirection.left:
                    viewController.hideOtherButtons(cellAnimating: self)
                    editButton.isHidden = false
                    deleteButton.isHidden = false
                    likedButton.isHidden = false
                    self.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.layer.transform = CATransform3DMakeScale(1.05,1.05,1)
                    },completion: { finished in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.layer.transform = CATransform3DMakeScale(1,1,1)
                        })
                    })
                case UISwipeGestureRecognizerDirection.right:
                    hideButtons()
                default:
                    return
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code called in tableView.dequeueReusableCell
        postedTitle.layer.masksToBounds = true
        postedTitle.layer.cornerRadius = 7
        postedRate.layer.masksToBounds = true
        postedRate.layer.cornerRadius = 7
        notifyLabel.layer.masksToBounds = true
        notifyLabel.layer.cornerRadius = 7
        editButton.layer.masksToBounds = true
        editButton.layer.cornerRadius = 15
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 15
        likedButton.layer.masksToBounds = true
        likedButton.layer.cornerRadius = 15
        notifyLabel.isHidden = true
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        if (self.isSelected) {
            self.setSelected(true, animated: false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            editButton.isHidden = true
            deleteButton.isHidden = true
            likedButton.isHidden = true
            if self.isEqual(viewController.wasSelected) {
                listingImages = postedListing.object(forKey: "images") as! [PFFile]
                let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "SearchDetailViewController") as! SearchDetailViewController
                vc.listingImages = listingImages
                viewController.present(vc, animated: true, completion: nil)
            }
            self.postedTitle.textColor = UIColor.white
            viewController.wasSelected = self
        } else {
            self.postedTitle.textColor = #colorLiteral(red: 0.07987072319, green: 0.733002007, blue: 0.8219559789, alpha: 1)
        }
    }
    
    @IBAction func deleteJob(_ sender: Any) {
        viewController.deleteJob(postedListing: postedListing)
    }
    
    @IBAction func editJob(_ sender: Any) {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
        vc.inEditMode = true
        vc.createObject = postedListing
        viewController.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func seeLiked(_ sender: Any) {
        let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "SelectViewController") as! SelectViewController
        vc.selectedListing = postedListing
        viewController.present(vc, animated: true, completion: nil)
    }
}
