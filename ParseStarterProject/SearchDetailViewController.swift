//
//  SearchDetailViewController.swift
//  ParseStarterProject
//
//  Created by mac on 5/4/18.
//  Copyright © 2018 iponwuzu. All rights reserved.
//

import UIKit

class SearchDetailViewController: CommonSourceController, UICollectionViewDataSource, UICollectionViewDelegate {

    var listingImages = [PFFile]()
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchDetailCell", for: indexPath) as! SearchDetailCollectionViewCell
        let listingImage = listingImages[indexPath.row]
        listingImage.getDataInBackground { (data, error) in
            if let data = data {
                let imageData = NSData(data: data)
                cell.searchDetailImage.image = UIImage(data: imageData as Data)
                cell.searchDetailImage.isHidden = false
                cell.searchDetailImage.sizeToFit()
                cell.searchDetailImage.frame = UIScreen.main.bounds
                cell.contentMode = UIViewContentMode.scaleAspectFill
                cell.clipsToBounds = true
                cell.searchDetailImage.contentMode = UIViewContentMode.scaleAspectFill
                cell.searchDetailImage.clipsToBounds = true
            }
        }
        return cell
    }
}
