//
//  SearchDetailCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by Lilo Onwuzu on 6/3/18.
//  Copyright © 2018 iponwuzu. All rights reserved.
//

import UIKit

class SearchDetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var searchDetailImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchDetailImage.layer.masksToBounds = true
    }
}
