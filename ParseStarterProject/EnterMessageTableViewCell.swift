//
//  EnterMessageTableViewCell.swift
//
//  Created by mac on 12/22/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class EnterMessageTableViewCell: UITableViewCell, UITextFieldDelegate {

    var selectedJob = PFObject(className: "Job")
    var myTableView = UITableView()
    var key = ""

    @IBOutlet weak var entertextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    func sendText() {
        if entertextField.text! != "" {
            let enteredText = entertextField.text!
            let reqId = selectedJob.object(forKey: "requesterId") as! String
            let userId = PFUser.current()?.objectId!
            
            // if requester id matches userId, send text as the requester with key "req" else send as "user"
            if reqId == userId {
                key = "req"
                
            } else {
                key = "user"
                
            }
            
            // save entered text with key "req" or "user"
            let newMessage: [String : String] = [key : enteredText]
            selectedJob.add(newMessage, forKey: "messages")
            selectedJob.saveInBackground(block: { (success, error) in
                if success {
                    self.myTableView.reloadData()
                    self.entertextField.text = ""
                    
                } else {
                    
                }
            })
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        entertextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func send(_ sender: UIButton) {
        sendText()
        
    }
    
    @IBAction func startTyping(_ sender: Any) {
        myTableView.contentInset.bottom = CGFloat(300)
        
    }
    
    @IBAction func stopTyping(_ sender: Any) {
        myTableView.contentInset.bottom = CGFloat(0)

    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendText()
        return true
        
    }
    
}
