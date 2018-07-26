//
//  CommonSourceController.swift
//
//  Created by mac on 10/21/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class CommonSourceController: UIViewController {
    
    var commonUser = PFUser()
    
    var sideBar: UIView!
    var state = true

    private func setUser(){
        let user = PFUser.current()
        if user?.email == nil || !(user?.isAuthenticated)! {
            directToLogin()
        } else {
            commonUser = user!
        }
    }
    
    public func getUser() -> PFUser {
        setUser()
        return commonUser
    }
    
    func directToLogin() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    func directToMain() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    func directToCreate() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    func getLocation(object : PFObject) {
        // add location with PFGeoPoint and use block for async call
        PFGeoPoint.geoPointForCurrentLocation { (coordinates, error) in
            if let coordinates = coordinates {
                object.setValue(coordinates, forKey: "location")
            } else {
                self.alertWithSingleOption(title: "Error Getting Location", message: "There was an issue getting your location. Allow uno to access your location through your phone settings")
            }
        }
    }
    
    func getMenu(mainView: UIView) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.willMove(toParentViewController: self)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        let sideView = vc.view.viewWithTag(55)!
        let height = self.view.bounds.height
        let rect = CGRect(x: 0, y: 0, width: 187, height: height)
        sideView.frame = rect
        sideView.isUserInteractionEnabled = true
        mainView.addSubview(sideView)
        sideView.isHidden = false
        sideBar = sideView
        sideBar.restorationIdentifier = "sideBar"
    }
    
    func moveRight(mainView: UIView) {
        let subviews = mainView.subviews
        print(subviews.count)
        for subview in subviews {
            // move all subviews to the right except sideBar with tag 55
            if (subview.tag != 55) {
                UIView.transition(with: subview,
                                  duration: 0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    subview.center.x += 187
                                    mainView.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    func moveLeft(mainView: UIView) {
        let subviews = mainView.subviews
        for subview in subviews {
            // move all subviews to the left except back image with tag 57
            if (subview.tag != 57) {
                UIView.transition(with: subview,
                                  duration: 0,
                                  options: .beginFromCurrentState,
                                  animations: {
                                    subview.center.x -= 187
                                    mainView.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    func showMenu(mainView: UIView) {
        if state {
            getMenu(mainView: mainView)
            moveRight(mainView: mainView)
            state = false
        } else {
            hideMenu(mainView: mainView)
            state = true
        }
    }
    
    func hideMenu(mainView: UIView) {
        if sideBar != nil && !sideBar.isHidden {
            sideBar.isHidden = true
            moveLeft(mainView: mainView)
        }
    }
    
    func alertWithSingleOption(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add alert action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        // present
        present(alert, animated: true, completion: nil)
    }
    
    func alertWithMultipleOptions(title: String, message: String, options: [String : String]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add alert action
        for option in options {
            alert.addAction(UIAlertAction(title: option.key, style: .default, handler: { (action) in
                if option.key == "Cancel" {
                    alert.dismiss(animated: true, completion: nil)
                    return;
                }
                if option.value != "" {
                    let action = NSSelectorFromString(option.value)
                    self.perform(action)
                }
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        // present
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func searchBar(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func createBar(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        directToCreate()
    }
    
    @IBAction func profileBar(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let user = getUser()
        vc.subjectUser = user
        vc.objectUser = user
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func listingsBar(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostedViewController") as! PostedViewController
        presentingViewController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logOutBar(_ sender: Any) {
        saveThenSignOff()
    }
    
    func showActivity() -> UIActivityIndicatorView {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let activityIndicator = UIActivityIndicatorView(frame: rect)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        // ignore all user interactions during login activity
        UIApplication.shared.beginIgnoringInteractionEvents()
        return activityIndicator
    }
    
    func restore(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func saveThenSignOff() {
        let empty = [String]()
        let user = getUser()
        // clear viewed jobs from user's filtering list then logout user
        user["accepted"] = empty
        user["rejected"] = empty
        user.saveInBackground(block: { (success, error) in
            if success {
                PFUser.logOut()
                self.directToMain()
            }
        })
    }
}

