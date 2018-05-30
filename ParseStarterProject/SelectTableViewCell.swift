//
//  SelectTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SelectTableViewCell: UITableViewCell {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()
    var ready = false
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var viewProfile: UIButton!
    @IBOutlet weak var cellBack: UILabel!
    @IBOutlet weak var swipeIcon: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    
    func recenterIcon () {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .transitionCrossDissolve,
                       animations: { self.swipeIcon.center.x += 30 },
                       completion: nil)
    }
    
    // drag function is called continuosly from start to end of a pan
    func dragged (gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.contentView)
        // continue executing dragged() function if pan is to the right, if not, do nothing, function terminates
        if translation.x > 0 {
            self.center.x = self.center.x + translation.x
            // once pan gesture ends, if selected cell, pass job in highlighted cell to selectVC, perform segue
            if gesture.state == UIGestureRecognizerState.ended {
                if self.center.x > (self.bounds.width/2) {
                    ready = true
                    // reload tableView to get "SelectVC" segue instruction
                    myTableView.reloadData()
                    
                }
                // reset cell center to center of screen
                self.center.x = self.bounds.width/2
                
            }
        }
    }
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
        cellBack.layer.masksToBounds = true
        cellBack.layer.cornerRadius = 10
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 45
        viewProfile.layer.cornerRadius = 45
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            // Configure the highlighted color for the selected state
            self.userName.textColor = UIColor.black
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .transitionCrossDissolve,
                           animations: { self.swipeIcon.center.x -= 30 },
                           completion: { (success) in
                            self.recenterIcon()
            
            })
            // attach pan gesture recognizer to each cell so whenever the selected cell is dragged, the dragged() function runs once
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.dragged(gesture:)))
            addGestureRecognizer(pan)
            
        } else {
            self.userName.textColor = UIColor.white
            
        } 
    }

}
