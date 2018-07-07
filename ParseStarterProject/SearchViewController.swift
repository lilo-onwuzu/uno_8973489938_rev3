//
//  SearchViewController.swift
//
//  Created by mac on 10/13/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import expanding_collection

class SearchViewController: CommonSourceController {
	
	@IBOutlet weak var backImage: UIImageView!
	@IBOutlet weak var objectTitle: UILabel!
	@IBOutlet weak var objectRate: UILabel!
	@IBOutlet weak var objectLocation: UILabel!
	@IBOutlet weak var numLike: UILabel!
	@IBOutlet weak var numLikeButton: UIButton!
	@IBOutlet weak var searchImage1: UIImageView!
	@IBOutlet weak var searchImage2: UIImageView!
	@IBOutlet weak var searchImage3: UIImageView!
	@IBOutlet weak var emptyLabel: UILabel!
	
	var activityIndicator = UIActivityIndicatorView()
	var listings = [PFObject]()
	var currentListing = PFObject(className: "Listings")
	var currentListingImages: [PFFile]!
	var index = 0
	var viewedListings = Set<String>()
	
	func flag() {
	}
	
	func hideAllViews() {
		searchImage1.isHidden = true
		searchImage2.isHidden = true
		searchImage3.isHidden = true
		objectTitle.isHidden = true
		objectRate.isHidden = true
		objectLocation.isHidden = true
		numLike.isHidden = true
		numLikeButton.isHidden = true
	}

	func showAllViews() {
		searchImage1.isHidden = false
		searchImage2.isHidden = false
		searchImage3.isHidden = false
		objectTitle.isHidden = false
		objectRate.isHidden = false
		objectLocation.isHidden = false
		numLike.isHidden = false
		numLikeButton.isHidden = false
	}
	
	func hideCards() {
		searchImage1.isHidden = true
		searchImage2.isHidden = true
		searchImage3.isHidden = true
	}
	
	func showCards() {
		searchImage1.isHidden = false
		searchImage2.isHidden = false
		searchImage3.isHidden = false
	}
	
	func addGestureRecognizers(img : UIImageView) {
		let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gestureRecognizer:)))
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gestureRecognizer:)))
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped(gestureRecognizer:)))
		swipeUp.direction = .up
		swipeRight.direction = .right
		swipeLeft.direction = .left
		img.addGestureRecognizer(swipeUp)
		img.addGestureRecognizer(swipeRight)
		img.addGestureRecognizer(swipeLeft)
	}
	
	func getDetails(listing: PFObject) -> [PFFile] {
		let title = listing.object(forKey: "title") as! String
		objectTitle.text = title
		let rate = listing.object(forKey: "rate") as! Int
		let cycle = listing.object(forKey: "cycle") as! String
		objectRate.text = "$" + String(rate) + " " + cycle
		let listingImages = listing.object(forKey: "images") as! [PFFile]
		let listingGeopoint = listing.object(forKey: "location") as! PFGeoPoint
		let user = super.getUser()
		let userGeopoint = user.object(forKey: "location") as! PFGeoPoint
		let distanceInMiles = listingGeopoint.distanceInMiles(to: userGeopoint)
		objectLocation.text = String(format: "%.0f", distanceInMiles) + " miles away"
		let liked = listing.object(forKey: "userAccepted") as! NSArray
		numLike.text = String(liked.count)
		return listingImages
	}
	
    func getListings() {
		activityIndicator = super.showActivity()
		let newQuery = PFQuery(className: "Listing")
		newQuery.limit = 3
//		newQuery.whereKey("objectId", notContainedIn: ignoredJobs)
		// query with PFUser's location
//		let location = user.object(forKey: "location") as? PFGeoPoint
//		if let latitude = location?.latitude {
//			if let longitude = location?.longitude {
//				newQuery.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast:PFGeoPoint(latitude:latitude + 1, longitude: longitude + 1))
				newQuery.findObjectsInBackground(block: { (listings, error) in
					super.restore(activityIndicator: self.activityIndicator)
					if let listings = listings {
						self.listings = listings
						self.showAllViews()
						for listing in listings {
							self.viewedListings.insert(listing.objectId!)
							self.showListing(index: self.index)
						}
						// initial animation with spring
						self.animateCardsOnInit()
						// get initial current listing, updated with every call to loopIndex()
						self.currentListing = listings[self.index]
						self.currentListingImages = self.getDetails(listing: self.currentListing)
					} else {
						// show no more listings alert and segue to home on action
						super.alertWithSingleOption(title: "There are no more jobs around your area", message: "Please check again later")
					}
				})
//			}
//		}
	}
	
	func getMainImage(listingImages: [PFFile], searchImage: UIImageView) {
		DispatchQueue.global(qos: .userInteractive).async {
			var image = UIImage()
			if listingImages.count > 0 {
				listingImages[0].getDataInBackground { (data, error) in
					if let data = data {
						let imageData = NSData(data: data)
						DispatchQueue.main.async {
							image = UIImage(data: imageData as Data)!
							searchImage.image = image
						}
					}
				}
			}
		}
	}
	
	func animateCardsOnInit() {
		let h = searchImage1.bounds.height
		UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: [], animations: {
			self.searchImage1.transform = CGAffineTransform(rotationAngle: 0)
		}) { (complete) in
			if (complete) {
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 40, options: [], animations: {
					self.searchImage2.transform = CGAffineTransform(rotationAngle: CGFloat.pi/36).translatedBy(x: (h/2)*(tan(CGFloat.pi/36)), y: -(h/4)*(tan(CGFloat.pi/36)))
				}) { (complete) in
					if (complete) {
						UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 40, options: [], animations: {
							self.searchImage3.transform = CGAffineTransform(rotationAngle: CGFloat.pi/18).translatedBy(x: (h/2)*(tan(CGFloat.pi/18)), y: -(h/4)*(tan(CGFloat.pi/18)))
						}) { (complete) in
							
						}
					}
				}
			}
		}
	}
	
	func animate(dur: TimeInterval, img: UIImageView, rot: CGFloat, tx: CGFloat, ty: CGFloat, wait: Bool, completion: (()->())?) {
		if completion == nil {
			UIView.animate(withDuration: dur) {
				img.transform = CGAffineTransform(rotationAngle: rot).translatedBy(x: tx, y: ty)
			}
			return;
		}
		UIView.animate(withDuration: dur, animations: {
			img.transform = CGAffineTransform(rotationAngle: rot).translatedBy(x: tx, y: ty)
		}) { (complete) in
			if (complete) {
				completion!()
			}
		}
	}
	
	func animateCards(gestureRecognizer: UISwipeGestureRecognizerDirection) {
		let swipe = gestureRecognizer
		let h = searchImage1.bounds.height
		let i = index % 3
		let rot1 = CGFloat.pi/36
		let rot2 = CGFloat.pi/18
		
		func shiftCardsLeft(i1: UIImageView, i2: UIImageView, i3: UIImageView) {
			// loop index and get card details before animation begins
			loopIndex(direction: .left)
			// query listing to get new listings.count before running hideUnusedCards(). this is an async task so listings.count is not updated till later. hideUnusedCards() should depend srongly on listings.count so if the async task takes longer than the delay from the animations, the card for the listing being obtained in the background should be hidden.
			queryListings()
			// no need to wait for async task as index does not depend on the growing listings array
			showListing(index: self.index)
			animate(dur: 1, img: i1, rot: -CGFloat.pi/3, tx: -5*h, ty: -5*h, wait: false, completion: nil)
			animate(dur: 0.125, img: i2, rot: 0.0, tx: 0, ty: 0, wait: true) {
				self.animate(dur: 0.25, img: i3, rot: rot1, tx: (h/2)*(tan(rot1)), ty: -(h/4)*(tan(rot1)), wait: true, completion: {
					self.view.insertSubview(i1, belowSubview: i3)
					self.animate(dur: 0.5, img: i1, rot: rot2, tx: (h/2)*(tan(rot2)), ty: -(h/4)*(tan(rot2)), wait: true, completion: {
						self.hideUnusedCards()
						//	after one index loop, i2 becomes the main image. after swipe, give swipe control to img now at p0 (i2)
						i2.isUserInteractionEnabled = true
						self.addGestureRecognizers(img: i2)
					})
				})
			}
		}
		
		func shiftCardsRight(i1: UIImageView, i2: UIImageView, i3: UIImageView) {
			//	pre-swipe postions
			//	i1 - image at p0 (12oclock), i2 - image at p1 (+18deg) , i3 - image at p2 (+36deg)
			loopIndex(direction: .right)
			showListing(index: self.index)
			self.view.insertSubview(i3, aboveSubview: i1)
			animate(dur: 0.125, img: i3, rot: 0.0, tx: 0, ty: 0, wait: true) {
				self.animate(dur: 0.25, img: i2, rot: rot2, tx: (h/2)*(tan(rot2)), ty: -(h/4)*(tan(rot2)), wait: true, completion: {
					self.animate(dur: 0.5, img: i1, rot: rot1, tx: (h/2)*(tan(rot1)), ty: -(h/4)*(tan(rot1)), wait: true, completion: {
						self.hideUnusedCards()
						// after post-swipe display, give swipe control to img now at p0 (i3)
						i3.isUserInteractionEnabled = true
						self.addGestureRecognizers(img: i3)
					})
				})
			}
		}
		
		switch i {
			case 0:
				// if index modulus is 0, searchImage1 is at p0 (12oclock) pre-swipe, searchImage2 is at p1 post-left-swipe, searchImage1 stays put at p0 post-right-swipe
				print("case0")
				if (swipe == .left) {
					shiftCardsLeft(i1: searchImage1, i2: searchImage2, i3: searchImage3)
				} else if (swipe == .right) {
					shiftCardsRight(i1: searchImage1, i2: searchImage2, i3: searchImage3)
				}
			case 1:
				// if index modulus is 1, searchImage2 is at p0 (12oclock) pre-swipe, searchImage3 is at p1 post-left-swipe, searchImage1 is at p0 post-right-swipe
				print("case1")
				if (swipe == .left) {
					shiftCardsLeft(i1: searchImage2, i2: searchImage3, i3: searchImage1)
				} else if (swipe == .right) {
					shiftCardsRight(i1: searchImage2, i2: searchImage3, i3: searchImage1)
				}
			case 2:
				print("case2")
				if (swipe == .left) {
					shiftCardsLeft(i1: searchImage3, i2: searchImage1, i3: searchImage2)
				} else if (swipe == .right) {
					shiftCardsRight(i1: searchImage3, i2: searchImage1, i3: searchImage2)
				}
			default:
				return
		}
	}
	
	func showListing(index: Int) {
		// use a circular pointer to move index and populate searchImage1-3
		let i = index % 3
		switch i {
			case 0:
				let listing1 = listings[index]
				let listing1Images = getDetails(listing: listing1)
				getMainImage(listingImages: listing1Images, searchImage: searchImage1)
			case 1:
				if index < listings.count {
					let listing2 = listings[index]
					let listing2Images = getDetails(listing: listing2)
					getMainImage(listingImages: listing2Images, searchImage: searchImage2)
				}
			case 2:
				if index < listings.count {
					let listing3 = listings[index]
					let listing3Images = getDetails(listing: listing3)
					getMainImage(listingImages: listing3Images, searchImage: searchImage3)
				}
			default:
				return
		}
	}
	
	func loopIndex(direction: UISwipeGestureRecognizerDirection) {
		let maxIndex = listings.count - 1
		if index >= 0 && index <= maxIndex {
			if direction == .left && index != maxIndex {
				index += 1
			} else if direction == .right && index != 0 {
				index -= 1
			}
		}
		currentListing = listings[index]
		currentListingImages = getDetails(listing: currentListing)
	}
	
	func queryListings() {
		// on getting the second to last card, query another listing
		if index >= listings.count - 2 {
			let newQuery = PFQuery(className: "Listing")
			newQuery.limit = 1
			let viewedArr = Array(viewedListings)
			newQuery.whereKey("objectId", notContainedIn: viewedArr)
			newQuery.findObjectsInBackground { (listings, error) in
				if let listings = listings {
					if listings.count > 0 {
						let listing = listings.first!
						if !self.viewedListings.contains(listing.objectId!) {
							self.viewedListings.insert(listing.objectId!)
							self.listings.append(listing)
						} else {
							self.queryListings()
						}
					}
				}
			}
		}
	}
	
	func hideUnusedCards() {
		let count = listings.count
		let i = index % 3
		if index >= count - 2 {
			switch i {
				case 0:
					if index == count - 2 {
						hideCards()
						//	if only two listings left, show current (searchImage1 when index%3== 0) and the one next to it
						searchImage1.isHidden = false
						searchImage2.isHidden = false
					} else if index == count - 1 {
						hideCards()
						// if only one listing left, show only current
						searchImage1.isHidden = false
					}
				case 1:
					if index == count - 2 {
						hideCards()
						searchImage2.isHidden = false
						searchImage3.isHidden = false
					} else if index == count - 1 {
						hideCards()
						searchImage2.isHidden = false
					}
				case 2:
					if index == count - 2 {
						hideCards()
						searchImage3.isHidden = false
						searchImage1.isHidden = false
					} else if index == count - 1 {
						hideCards()
						searchImage2.isHidden = false
					}
				default:
					return
			}
		} else {
			showCards()
		}
	}
	
	@objc func swiped(gestureRecognizer: UISwipeGestureRecognizer) {
		let swipe = gestureRecognizer
		if swipe.state == .recognized {
			switch swipe.direction {
				case UISwipeGestureRecognizerDirection.right:
					animateCards(gestureRecognizer: .right)
					print("Recognized right")
					print(index)
				case UISwipeGestureRecognizerDirection.left:
					// on left swipe, if index is at max, don't proceed with animations
					if index == listings.count - 1 {
						hideAllViews()
						emptyLabel.isHidden = false
						return
					}
					animateCards(gestureRecognizer: .left)
					print("Recognized left")
					print(index)
				default:
					break
			}
		}
		if swipe.state == .ended {
			switch swipe.direction {
				case UISwipeGestureRecognizerDirection.up:
					self.performSegue(withIdentifier: "toSearchDetail", sender: self)
				default:
					break
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		hideAllViews()
		objectTitle.layer.masksToBounds = true
		objectTitle.layer.cornerRadius = 10
		objectRate.layer.masksToBounds = true
		objectRate.layer.cornerRadius = 10
		objectLocation.layer.masksToBounds = true
		objectLocation.layer.cornerRadius = 10
		backImage.layer.masksToBounds = true
		backImage.layer.cornerRadius = 45
		searchImage1.layer.borderWidth = 2
		searchImage1.layer.borderColor = UIColor.white.cgColor
		searchImage1.layer.masksToBounds = true
		searchImage1.layer.cornerRadius = 15
		searchImage2.layer.borderWidth = 2
		searchImage2.layer.borderColor = UIColor.white.cgColor
		searchImage2.layer.masksToBounds = true
		searchImage2.layer.cornerRadius = 15
		searchImage3.layer.borderWidth = 2
		searchImage3.layer.borderColor = UIColor.white.cgColor
		searchImage3.layer.masksToBounds = true
		searchImage3.layer.cornerRadius = 15
		searchImage1.isUserInteractionEnabled = true
		emptyLabel.layer.masksToBounds = true
		emptyLabel.layer.cornerRadius = 15
		emptyLabel.layer.borderWidth = 2
		emptyLabel.layer.borderColor = UIColor.white.cgColor
		addGestureRecognizers(img: searchImage1)
		getListings()
	}
	
	@IBAction func home(_ sender: Any) {
		super.showMenu(mainView: self.view)
	}
	
	@IBAction func likeListing(_ sender: Any) {
		let user = super.getUser()
		let userId = user.objectId!
		currentListing.addUniqueObject(userId, forKey: "userAccepted")
		currentListing.saveInBackground { (success, error) in
			if (success) {
				let accepted = self.currentListing.object(forKey: "userAccepted") as! NSArray
				self.numLike.text = String(accepted.count)
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toSearchDetail" {
			let vc = segue.destination as! SearchDetailViewController
			vc.listingImages = currentListingImages
			vc.listing = currentListing
		}
	}
}
