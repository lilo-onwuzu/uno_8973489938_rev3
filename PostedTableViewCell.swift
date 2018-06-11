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
    var viewController: UIViewController!
    var postedListing = PFObject(className: "Listing")
    
    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @objc func swiped(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
            case UISwipeGestureRecognizerDirection.right:
                editButton.isHidden = false
                deleteButton.isHidden = false
            default:
                return
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the highlighted color for the selected state
        if selected {
            self.postedTitle.textColor = UIColor.black
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(swipe:)))
            self.addGestureRecognizer(swipe)
//            self.viewController.performSegue(withIdentifier: "toSelect", sender: self)
        } else {
            self.postedTitle.textColor = UIColor.white
            editButton.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    @IBAction func deleteJob(_ sender: Any) {
        let alert = UIAlertController(title: "Deleting Job", message: "Are you sure you want to delete this job?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Abort", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
            self.postedListing.deleteInBackground { (success, error) in
                if (success) {
                        self.myTableView.reloadData()
                        alert.dismiss(animated: true, completion: nil)
                }
            }
        }))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editJob(_ sender: Any) {
//        let storyboard = UIStoryboard.init()
//        let vc = storyboard.instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
//        myTableView.present
//        present(vc, animated: true, completion: nil)
    }
}
