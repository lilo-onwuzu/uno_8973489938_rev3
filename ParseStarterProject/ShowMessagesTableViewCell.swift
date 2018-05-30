//
//  ShowMessagesTableViewCell.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ShowMessagesTableViewCell: UITableViewCell {
        
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        message.layer.masksToBounds = true
        message.layer.cornerRadius = 5
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = 28
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
