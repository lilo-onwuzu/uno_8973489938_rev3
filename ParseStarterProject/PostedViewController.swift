//
//  PostedViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedViewController: CommonSourceController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postedListings = [PFObject]()
    var refresher: UIRefreshControl!
//    var activityIndicator = UIActivityIndicatorView()
    var wasSelected: PostedTableViewCell!
    
    @objc func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    func getPostedListings() {
        let activityIndicator = super.showActivity()
        let user = super.getUser()
        let userId = user.objectId!
        let query = PFQuery(className: "Listing")
        query.whereKey("requesterId", equalTo: userId)
        query.findObjectsInBackground { (listings, error) in
            super.restore(activityIndicator: activityIndicator)
            if let listings = listings {
                if listings.count > 0 {
                    self.postedListings = listings
                    // reload data after async query
                    self.tableView.reloadData()
                } else {
                    // TO DO : handle no listings
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        getPostedListings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reload tableView to remove gesture recognizers
        tableView.reloadData()
    }
    
    @IBAction func home(_ sender: Any) {
        super.showMenu(mainView: self.view)
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedListings.count
    }
    
    func deleteRow(listing: PFObject) {
        tableView.reloadData()
//        let alert = UIAlertController(title: "Deleting Job", message: "Are you sure you want to delete this job?", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Abort", style: .default, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
//            self.postedListing.deleteInBackground { (success, error) in
//                if (success) {
//                    print("SUCCESS")
//                    self.myTableView.reloadData()
//                }
//            }
//            alert.dismiss(animated: true, completion: nil)
//            
//        }))
//        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedCell", for: indexPath) as! PostedTableViewCell
        let listing = postedListings[indexPath.row]
        let postedTitle = listing.object(forKey: "title") as! String
        let postedCycle = listing.object(forKey: "cycle") as! String
        let postedRate = listing.object(forKey: "rate") as! Int
        let interested = listing.object(forKey: "userAccepted") as! NSArray
        cell.postedTitle?.text = postedTitle
        cell.postedRate?.text = "$" + String(postedRate) + " " + postedCycle
        cell.notifyLabel.text = String(interested.count) + " INTERESTED!"
        // tableView is given to cell to allow us to reload the tableview from inside cell
        cell.myTableView = tableView
        cell.viewController = self
        cell.postedListing = listing
        return cell
    }

    //  touch anywhere to hide menuView. showMenu prevents the need for a double tap before menuView can be displayed again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.showMenu(mainView: self.view)
    }
}
