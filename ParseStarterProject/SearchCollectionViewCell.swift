//
//  SearchCollectionViewCell.swift
//  ParseStarterProject
//
//  Created by mac on 5/1/18.
//  Copyright © 2018 iponwuzu. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var searchImage: UIImageView!
    
    var listingImages = [PFFile]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchImage.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: self, action: Selector(("respondToSwipe:")))
        self.addGestureRecognizer(swipe)
        searchImage.isHidden = true
        searchImage.layer.borderWidth = 2
        searchImage.layer.borderColor = UIColor.white.cgColor
        searchImage.layer.masksToBounds = true
        searchImage.layer.cornerRadius = 15
    }
    
    func respondToSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        let gesture = gestureRecognizer
        switch gesture.direction {
            case UISwipeGestureRecognizerDirection.up :
                print("SWIPE UP")
            default:
                print("DEFAULT")
        }
    }
    
//    override var isSelected: Bool {
//        didSet{
//            if self.isSelected {
//                self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            } else {
//                self.transform = CGAffineTransform.identity
//            }
//        }
//    }
}
