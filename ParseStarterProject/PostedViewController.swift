//
//  PostedViewController.swift
//
//  Created by mac on 11/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class PostedViewController: CommonSourceController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var showMenu = false
    var user = PFUser.current()!
    var postedListings = [PFObject]()
    // saves selected job(s) so it can be deleted
    var jobsToDelete = [PFObject]()
    // saves selected job so it can be passed along before segue to edit vc
    var editJob = PFObject(className: "Job")
    // saves selected job so it can be passed along before segue to select vc
    var selectedJob = PFObject(className: "Job")
    var deleting = false
    var refresher: UIRefreshControl!
    var activityIndicator = UIActivityIndicatorView()
    
    // get rows selected for deleting and returns the job objects
    func getRowsToDelete() -> [PFObject] {
        var deleteRows = [PFObject]()
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                deleteRows.append(postedListings[indexPath.row])
            }
        }
        return deleteRows
    }
    
    func deleteAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        // add alert action
//        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
//        // add alert action
//        alert.addAction(UIAlertAction(title: "Yes Delete", style: .default, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//            // run delete process if "Yes Delete" is selected
//            for job in self.jobsToDelete {
//                let id = job.objectId!
//                // for loop within for loop to compare each row/job selected for deletion with the current list of posted jobs
//                for postedJob in self.postedJobs {
//                    if id == postedJob.objectId {
//                        self.postedJobs.remove(at: (self.postedJobs.index(of: postedJob))!)
//                        let query = PFQuery(className: "Job")
//                        query.whereKey("objectId", equalTo: id)
//                        query.findObjectsInBackground(block: { (objects, error) in
//                            if let objects = objects {
//                                for object in objects {
//                                    object.deleteInBackground(block: { (success, error) in
//                                        if let error = error {
//                                            super.alertWithSingleOption(title: "Error Deleting Job", message: error.localizedDescription)
//                                        } else {
//                                            // reload table after deleting cells
//                                            self.tableView.reloadData()
//                                            self.tableView.allowsMultipleSelection = false
//                                        }
//                                    })
//                                }
//                            }
//                        })
//                    }
//                }
//            }
//        }))
//        present(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        self.tableView.reloadData()
        self.refresher.endRefreshing()
    }

    
    // hide menuView on viewDidAppear so if user presses back to return to this view, menuView is hidden. showMenu prevents the need for a double tap before menuView can be displayed again
    func removeMenu() {
//        menuView.isHidden = true
        showMenu = true
        
    }
    
    func getPostedListings() {
        // collect user's posted jobs from a query to "Listing" class
        let userId = user.object(forKey: "objectId") as! String
        activityIndicator = super.showActivity()
        let query = PFQuery(className: "Listing")
        query.whereKey("requesterId", equalTo: userId)
        query.findObjectsInBackground { (listings, error) in
            if let listings = listings {
                if listings.count > 0 {
                    self.postedListings = listings
                    // reload data after async query
                    self.tableView.reloadData()
                    super.restore(activityIndicator: self.activityIndicator)
                } else {
                    //                    self.emptyLabel.isHidden = false
                    
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
        removeMenu()
        // reload tableView to remove gesture recognizers
        tableView.reloadData()
    }
    
    @IBAction func home(_ sender: Any) {
        super.showMenu(mainView: self.view)
    }
    
    @IBAction func editJob(_ sender: Any) {
//        if let index = tableView.indexPathForSelectedRow?.row {
//            // pass selected job to editJob segue once editJob is clicked
//            editJob = postedJobs[index]
//            performSegue(withIdentifier: "toEditJob", sender: self)
//        // if no jobs are selected, show error/guide
//        } else {
//            super.alertWithSingleOption(title: "Select a job to edit", message: "You have not selected any jobs")
//        }
    }
    
    @IBAction func triggerDelete(_ sender: Any) {
        // if deleting is in process
        if deleting {
//            deleteLabel.isHidden = true
            deleting = false
            var jobTitles = ""
            
            // get the array of PFObjects selected for deletion, could be empty if no selection was made
            jobsToDelete = getRowsToDelete()
            let deleteCount = jobsToDelete.count
            
            // if there were rows selected for deletion, display deleteAlert. Else dont show alert
            if deleteCount > 0 {
                // delete jobs in Parse
                for job in jobsToDelete {
                    let jobTitle = job.object(forKey: "title") as! String
                    jobTitles += jobTitle + " \n"
                }
                // deletes "object" in "objects" then reloads tableview, resets deleteButton title and stops allowing multiple selections
                self.deleteAlert(title: "Are you sure you want to delete these jobs?", message: jobTitles)
            }
            tableView.allowsMultipleSelection = false
        } else {
//            deleteLabel.isHidden = false
            tableView.allowsMultipleSelection = true
            // start animating cells and activate delete trigger "deleting"
            deleting = true
        }
    }
            
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedListings.count
    }
    
    // UITableView Delegate method operates on my UITableView subclass "tableView"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postedCell", for: indexPath) as! PostedTableViewCell
//        // this performs segue when cell is swiped tableview is reloaded and this function terminates here
//        if cell.ready {
//            // reset ready variable
//            cell.ready = false
//            // save selectedJon for select vc
//            selectedJob = postedJobs[cell.selectedRow]
//            performSegue(withIdentifier: "toSelect", sender: self)
//        }
//
//        // get user's images and other cell details
//        let imageFile = user.object(forKey: "image") as! PFFile
//        imageFile.getDataInBackground { (data, error) in
//            if let data = data {
//                let imageData = NSData(data: data)
////                cell.userImage.image = UIImage(data: imageData as Data)
//            }
//        }
        let listing = postedListings[indexPath.row]
        let postedTitle = listing.object(forKey: "title") as! String
        let postedCycle = listing.object(forKey: "cycle") as! String
        let postedRate = listing.object(forKey: "rate") as! String
        cell.postedTitle?.text = postedTitle
        cell.postedRate?.text = "$" + postedRate + " " + postedCycle
//        // return some other variables needed for operations within the respective cells for instance, tableView is given to cell to allow us to reload the tableview from inside cell
//        cell.myTableView = tableView
        return cell
    }

    //  touch anywhere to hide menuView. showMenu prevents the need for a double tap before menuView can be displayed again
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeMenu()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditJob" {
            let vc = segue.destination as! EditJobViewController
            vc.editJob = self.editJob
        }
        if segue.identifier == "toSelect" {
            let vc = segue.destination as! SelectViewController
            vc.selectedJob = self.selectedJob
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

}
