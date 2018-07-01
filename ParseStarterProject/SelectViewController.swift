//
//  SelectViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class SelectViewController: CommonSourceController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedListing = PFObject(className: "Listing")
    var usersAccepted = [String]()
    var refresher: UIRefreshControl!
    
    func refresh() {
        tableView.reloadData()
        self.refresher.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersAccepted = selectedListing.object(forKey: "userAccepted") as! [String]
        //      TO DO : handle when no users have accepted
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // reload tableView to remove gesture recognizers
        tableView.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersAccepted.count
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell", for: indexPath) as! SelectTableViewCell
        let queryUser: PFQuery = PFUser.query()!
        queryUser.whereKey("objectId", equalTo: usersAccepted[indexPath.row])
        queryUser.getFirstObjectInBackground { (user, error) in
            if let userAccepted = user {
                cell.userAccepted = userAccepted
                let firstName = userAccepted.object(forKey: "first_name") as! String
                let lastName = userAccepted.object(forKey: "last_name") as! String
                cell.userNameField.text = firstName + " " + lastName
                cell.userNameField.isHidden = false
                if let imageFile = userAccepted.object(forKey: "image") as? PFFile {
                    imageFile.getDataInBackground { (data, error) in
                        if let data = data {
                            let imageData = NSData(data: data)
                            cell.userImage.image = UIImage(data: imageData as Data)
                            cell.userImage.isHidden = false
                        }
                    }
                }
            } else {
                // TO DO : handle error getting user
            }
        }
        cell.myTableView = tableView
        cell.viewController = self
        cell.selectedListing = self.selectedListing
        return cell
    }
}
