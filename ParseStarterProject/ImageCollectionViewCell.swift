//
//  ImageCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by mac on 1/17/18.
//  Copyright © 2018 iponwuzu. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.isHidden = false
        deleteButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 15
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
    }
}
