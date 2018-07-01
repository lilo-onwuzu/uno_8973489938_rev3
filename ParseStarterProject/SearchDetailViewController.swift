//
//  SearchDetailViewController.swift
//  ParseStarterProject
//
//  Created by mac on 5/4/18.
//  Copyright © 2018 iponwuzu. All rights reserved.
//

import UIKit

class SearchDetailViewController: CommonSourceController {

    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var listing = PFObject(className: "Listings")
    var listingImages = [PFFile]()
    var index = 0
    
    func getImage(index: Int) {
        if listingImages.count > 0 {
            let listingImage = listingImages[index]
            listingImage.getDataInBackground { (data, error) in
                if let data = data {
                    let imageData = NSData(data: data)
                    self.searchImage.image = UIImage(data: imageData as Data)
                }
            }
        } else {
            // TO DO : Handle no images case
        }
    }
    
    func loopIndex(direction: UISwipeGestureRecognizerDirection) {
        let maxIndex = listingImages.count - 1
        if index >= 0 && index <= maxIndex {
            if direction == .left && index != maxIndex {
                index += 1
            } else if direction == .right && index != 0 {
                index -= 1
            }
        }
    }
    
    func getDetails() {
        let details = listing.object(forKey: "details") as? String
        detailsLabel.text = details
    }
    
    @objc func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
        let swipe = gestureRecognizer
        if swipe.state == .ended {
            switch swipe.direction {
                case UISwipeGestureRecognizerDirection.up:
                    detailsView.isHidden = false
                case UISwipeGestureRecognizerDirection.down:
                    if (!detailsView.isHidden) {
                        detailsView.isHidden = true
                    } else {
                        dismiss(animated: true, completion: nil)
                    }
                case UISwipeGestureRecognizerDirection.right:
                    print("right")
                    loopIndex(direction: .right)
                    getImage(index: index)
                case UISwipeGestureRecognizerDirection.left:
                    loopIndex(direction: .left)
                    getImage(index: index)
                default:
                    return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(gestureRecognizer:)))
        swipeUp.direction = .up
        swipeDown.direction = .down
        swipeRight.direction = .right
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        getImage(index: index)
        getDetails()
    }
}
