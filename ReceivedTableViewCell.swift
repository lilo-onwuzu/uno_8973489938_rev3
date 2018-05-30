//
//  ReceivedTableViewCell.swift
//
//  Created by mac on 11/28/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ReceivedTableViewCell: UITableViewCell {

    @IBOutlet weak var matchTitle: UILabel!
    @IBOutlet weak var matchRate: UILabel!
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var viewListing: UIButton!
    @IBOutlet weak var unmatch: UIButton!
    
    var ready = false
    var myTableView = UITableView()
    var selectedRow = Int()
    
    
    func recenterIcon () {
//        UIView.animate(withDuration: 1,
//                       delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.0,
//                       options: .transitionCrossDissolve,
//                       animations: { self.matchIcon.center.y += 20 },
//                       completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        matchTitle.layer.masksToBounds = true
        matchTitle.layer.cornerRadius = 7
        matchRate.layer.masksToBounds = true
        matchRate.layer.cornerRadius = 7
        notifyLabel.layer.masksToBounds = true
        notifyLabel.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the highlighted color for the selected state
//        if selected {
//            self.receivedTitle.textColor = UIColor.black
//            matchIcon.isHidden = false
//            matchLabel.isHidden = false
//            UIView.animate(withDuration: 0.25,
//                           delay: 0,
//                           usingSpringWithDamping: 0.6,
//                           initialSpringVelocity: 0.0,
//                           options: .transitionCrossDissolve,
//                           animations: { self.matchIcon.center.y -= 20 },
//                           completion: { (success) in
//                            self.recenterIcon()
//
//            })
//        } else {
//            self.receivedTitle.textColor = UIColor.white
//            matchIcon.isHidden = true
//            matchLabel.isHidden = true
//
//        }
    }
    
}
