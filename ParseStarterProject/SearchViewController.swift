//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import expanding_collection

class SearchViewController: CommonSourceController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	@IBOutlet weak var backImage: UIImageView!
	@IBOutlet weak var objectTitle: UILabel!
	@IBOutlet weak var objectRate: UILabel!
	@IBOutlet weak var objectLocation: UILabel!
	@IBOutlet weak var numLike: UILabel!
	@IBOutlet weak var searchCollection: UICollectionView!
	
	var viewedJobId = String()
	var keepId = String()
	let user = PFUser.current()!
	var currentListing = PFObject(className: "Listings")
	var secondQuery = false
	var ignoredJobs = [String]()
	var activityIndicator = UIActivityIndicatorView()
	var listings = [PFObject]()
	var listingImages = [PFFile]()
	
	func flag() {
	}
	
	func hideView() {
		searchCollection.isHidden = true
		objectTitle.isHidden = true
		objectRate.isHidden = true
		objectLocation.isHidden = true
		numLike.isHidden = true
	}

	func showView() {
		searchCollection.isHidden = false
		objectTitle.isHidden = false
		objectRate.isHidden = false
		objectLocation.isHidden = false
		numLike.isHidden = false
	}
	
	func getDetails(listing: PFObject) -> [PFFile] {
		let title = listing.object(forKey: "title") as! String
		objectTitle.text = title
		let rate = listing.object(forKey: "rate") as! String
		let cycle = listing.object(forKey: "cycle") as! String
		objectRate.text = "$" + rate + " " + cycle
		listingImages = listing.object(forKey: "images") as! [PFFile]
		let listingGeopoint = listing.object(forKey: "location") as! PFGeoPoint
		let userGeopoint = user.object(forKey: "location") as! PFGeoPoint
		let distanceInMiles = listingGeopoint.distanceInMiles(to: userGeopoint)
		objectLocation.text = String(format: "%.0f", distanceInMiles) + " miles away"
		return listingImages
	}
	
    func getListings() {
		activityIndicator = super.showActivity()
		let newQuery = PFQuery(className: "Listing")
		newQuery.limit = 5
//		newQuery.whereKey("objectId", notContainedIn: ignoredJobs)
		// query with PFUser's location
		let location = user.object(forKey: "location") as? PFGeoPoint
		if let latitude = location?.latitude {
			if let longitude = location?.longitude {
				newQuery.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast:PFGeoPoint(latitude:latitude + 1, longitude: longitude + 1))
			}
		}
		newQuery.findObjectsInBackground(block: { (listings, error) in
			super.restore(activityIndicator: self.activityIndicator)
			if let listings = listings {
				self.listings = listings
				self.searchCollection.reloadData()
			} else {
				// show no more listings alert and segue to home on action
				super.alertWithSingleOption(title: "There are no more jobs around your area", message: "Please check again later")
			}
		})
	}
	
    func drag(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self.objectImage)
//
//		switch gesture.state {
//		case .began:
//			let initialTouchPoint = gesture.location(in: self.view)
//			let newAnchorPoint = CGPoint(x: initialTouchPoint.x / view.bounds.width, y: initialTouchPoint.y / view.bounds.height)
//			let oldPosition = CGPoint(x: view.bounds.size.width * objectImage.layer.anchorPoint.x, y: view.bounds.size.height * objectImage.layer.anchorPoint.y)
//			let newPosition = CGPoint(x: view.bounds.size.width * newAnchorPoint.x, y: view.bounds.size.height * newAnchorPoint.y)
//			objectImage.layer.anchorPoint = newAnchorPoint
//			objectImage.layer.position = CGPoint(x: view.layer.position.x - oldPosition.x + newPosition.x, y: objectImage.layer.position.y - oldPosition.y + newPosition.y)
//
////			removeAnimations()
//			objectImage.layer.rasterizationScale = UIScreen.main.scale
//			objectImage.layer.shouldRasterize = true
//			delegate?.didBeginSwipe(onView: self)
//		case .changed:
//			let rotationStrength = 0.5
//			let rotationAngle = -CGFloat(Double.pi) / 10.0
//
//			var transform = CATransform3DIdentity
//			transform = CATransform3DRotate(transform, CGFloat(rotationAngle), 0, 0, 1)
//			transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
//			objectImage.layer.transform = transform
//		case .ended:
//			endedPanAnimation()
//			objectImage.layer.shouldRasterize = false
//		default:
//			resetCardViewPosition()
//			objectImage.layer.shouldRasterize = false
//		}
//        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
//        let scale = min(100 / abs(xFromCenter), 1)
//        var stretch = rotation.scaledBy(x: scale, y: scale)
//        objectImage.transform = stretch

		// once panning ends, record swipe left or right action, filter viewed job from showing up later, reset swipe element to initial position then finally fetch a new job
//        if gesture.state == UIGestureRecognizerState.ended {
//            var acceptedOrRejected = ""
//            if xFromCenter > 100 {
//                let userId = user.objectId!
//                let reqId = currentJob.object(forKey: "requesterId") as! String
//                // enable so user cannot accept their own job
//                if userId != reqId {
//					acceptedOrRejected = "accepted"
//					currentJob.addUniqueObject(user.objectId!, forKey: "userAccepted")
//					currentJob.saveInBackground()
//					// animate (flip wheelbarrow horozontally) to show success
//					UIView.animate(withDuration: 3,
//								   delay: 0,
//								   usingSpringWithDamping: 0.6,
//								   initialSpringVelocity: 0.0,
//								   options: [],
//								   animations: {
//									self.reqImage.transform = CGAffineTransform(rotationAngle: .pi)
//					}, completion: nil)
//				} else {
//					super.alertWithSingleOption(title: "Swipe Left", message: "WorkJet does not allow its users to accept their own jobs")
//				}
//			} else if xFromCenter < -100 {
//				acceptedOrRejected = "rejected"
//			}
//			// enable so user only sees one job once during a log in session
//			if acceptedOrRejected != "" {
//				PFUser.current()?.addUniqueObject(viewedJobId, forKey:acceptedOrRejected)
//				PFUser.current()?.saveInBackground()
//			}
			
			// recenter wheelbarrow and reset orientation
//			objectImage.center.x = self.view.center.x
//			objectImage.center.y = self.view.center.y - 43.5
//			rotation = CGAffineTransform(rotationAngle: 0)
//			stretch = rotation.scaledBy(x: 1, y: 1)
//			reqImage.transform = stretch
//			//            getNewJob()
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		hideView()
		objectTitle.layer.masksToBounds = true
		objectTitle.layer.cornerRadius = 10
		objectRate.layer.masksToBounds = true
		objectRate.layer.cornerRadius = 10
		objectLocation.layer.masksToBounds = true
		objectLocation.layer.cornerRadius = 10
		backImage.layer.masksToBounds = true
		backImage.layer.cornerRadius = 45
		showView()
        getListings()
	}
	
	@IBAction func home(_ sender: Any) {
		super.showMenu(mainView: self.view)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toSearchDetail" {
			let vc = segue.destination as! SearchDetailViewController
			vc.listingImages = listingImages
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return listings.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCollectionViewCell
		let listing = listings[indexPath.row]
		let listingImages = getDetails(listing: listing)
		cell.listingImages = listingImages
		if listingImages.count > 1 {
			listingImages[0].getDataInBackground { (data, error) in
				if let data = data {
					let imageData = NSData(data: data)
					cell.searchImage.image = UIImage(data: imageData as Data)
					cell.searchImage.isHidden = false
				}
			}
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		performSegue(withIdentifier: "toSearchDetail", sender: self)
	}
	
}
