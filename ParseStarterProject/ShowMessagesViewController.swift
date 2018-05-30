//
//  ShowMessagesViewController.swift
//
//  Created by mac on 11/29/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class ShowMessagesViewController: CommonSourceController, UITableViewDelegate, UITableViewDataSource {

    var selectedJob = PFObject(className: "Job")
    var refresher: UIRefreshControl!
    var messages = [NSDictionary]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.layer.masksToBounds = true
        logo.layer.cornerRadius = 3
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Refreshing...")
        refresher.addTarget(self, action: #selector(PostedViewController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        jobTitle.text = selectedJob.object(forKey: "title") as? String
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        // change view for smaller screen sizes (iPad, iPhone5 & iPhone5s)
        if UIScreen.main.bounds.height <= 650 {
            self.view.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
            return 1
        
        // section 0 is for entry textfield and send button so we only need one row for this section
        } else {
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // set contentview constraints on all four sides
        return UITableViewAutomaticDimension

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // for section with rows of messages from selectedJob PFObject
            let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ShowMessagesTableViewCell
            messages = selectedJob.object(forKey: "messages") as! [NSDictionary]
            
            // pass details to listCell
            // place workjet's intro message in first indexpath
            if indexPath.row == 0 {
                let dictionary = messages[0]
                let introMessage = dictionary.object(forKey: "intro") as! String
                cell.message.text = introMessage
                cell.userImage.image = UIImage(named: "appIcon.png")
                
            } else {
                // place other messages between requester and user in other indexpaths
                let dictionary = messages[indexPath.row]
                // optionally bind both message from req and message from user to variable "message" so that whichever one that is called can be read
                let message_req = dictionary.object(forKey: "req") as? String
                let message_user = dictionary.object(forKey: "user") as? String
                if let message = message_req {
                    cell.message.text = message
                    // get image for requester and display
                    let reqId = selectedJob.object(forKey: "requesterId") as! String
                    var requester = PFObject(className: "User")
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: reqId)
                    query.findObjectsInBackground { (users, error) in
                        if let users = users {
                            requester = users[0]
                            let imageFile = requester.object(forKey: "image") as! PFFile
                            imageFile.getDataInBackground { (data, error) in
                                if let data = data {
                                    let imageData = NSData(data: data)
                                    cell.userImage.image = UIImage(data: imageData as Data)
                                    
                                }
                            }
                        }
                    }
                } else if let message = message_user {
                    cell.message.text = message
                    // get image for selectedUser and display
                    let reqId = selectedJob.object(forKey: "selectedUser") as! String
                    var requester = PFObject(className: "User")
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: reqId)
                    query.findObjectsInBackground { (users, error) in
                        if let users = users {
                            requester = users[0]
                            let imageFile = requester.object(forKey: "image") as! PFFile
                            imageFile.getDataInBackground { (data, error) in
                                if let data = data {
                                    let imageData = NSData(data: data)
                                    cell.userImage.image = UIImage(data: imageData as Data)
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            return cell
            
        } else {
            // for section with entry message textfield and send button
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EnterMessageTableViewCell
            
            // pass details to entryCell
            // pass selectedJob to cell so we can add new messages when send is tapped
            cell.selectedJob = selectedJob
            // pass tableView so we can reload tableView from within cell whenever send is tapped
            cell.myTableView = tableView
            
            return cell
            
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
