//
//  PostedTableViewCell.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedTableViewCell: UITableViewCell {
    
//    var myTableView = UITableView()
    var ready = false
    var selectedRow = Int()
    
    @IBOutlet weak var postedTitle: UILabel!
    @IBOutlet weak var postedRate: UILabel!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
//
//    func recenter () {
////        UIView.animate(withDuration: 0.5,
////                       delay: 0,
////                       usingSpringWithDamping: 0.6,
////                       initialSpringVelocity: 0.0,
////                       options: .transitionCrossDissolve,
////                       animations: { self.swipeIcon.center.x += 30 },
////                       completion: nil)
//    }
    
    // drag function is called continuosly from start to end of a pan
//    func dragged (gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self.contentView)
//        // continue executing dragged() function if pan is to the right, if not, do nothing, function terminates
//
//        if translation.x > 0 {
//            self.center.x = self.center.x + translation.x
//            // once pan gesture ends, if selected cell , pass job in highlighted cell to selectVC, perform segue
//
//            if gesture.state == UIGestureRecognizerState.ended {
//                if self.center.x > (self.bounds.width/2) {
//                    ready = true
//                    if let row = myTableView.indexPathForSelectedRow?.row {
//                        selectedRow = row
//                        // reload tableView to get "SelectVC" segue instruction
//                        myTableView.reloadData()
//
//                    }
//                }
//                // reset cell center to center of screen
//                self.center.x = self.bounds.width/2
//
//            }
//
//        }
//
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postedTitle.layer.masksToBounds = true
        postedTitle.layer.cornerRadius = 7
        postedRate.layer.masksToBounds = true
        postedRate.layer.cornerRadius = 7
        notifyLabel.layer.masksToBounds = true
        notifyLabel.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the highlighted color for the selected state
//        if selected {
//            self.postedTitle.textColor = UIColor.black
////            UIView.animate(withDuration: 0.5,
////                           delay: 0,
////                           usingSpringWithDamping: 0.6,
////                           initialSpringVelocity: 0.0,
////                           options: .transitionCrossDissolve,
////                           animations: { self.swipeIcon.center.x -= 30 },
////                           completion: { (success) in
////                            self.recenter()
////
////            })
//            // attach pan gesture recognizer to each cell so whenever the selected cell is dragged, the dragged() function runs once
//            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.dragged(gesture:)))
//            self.addGestureRecognizer(pan)
//
//        } else {
//            self.postedTitle.textColor = UIColor.white
//
//        }
    }

}
