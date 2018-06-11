//
//  HomeViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit

class HomeViewController: CommonSourceController {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var listingsButton: UIButton!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var searchBarButton: UIButton!
    @IBOutlet weak var createBarButton: UIButton!
    @IBOutlet weak var profileBarButton: UIButton!
    @IBOutlet weak var listingsBarButton: UIButton!
    @IBOutlet weak var logOutBarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarButton.layer.masksToBounds = true
        searchBarButton.layer.cornerRadius = 10
        createBarButton.layer.masksToBounds = true
        createBarButton.layer.cornerRadius = 10
        profileBarButton.layer.masksToBounds = true
        profileBarButton.layer.cornerRadius = 10
        listingsBarButton.layer.masksToBounds = true
        listingsBarButton.layer.cornerRadius = 10
        logOutBarButton.layer.masksToBounds = true
        logOutBarButton.layer.cornerRadius = 10
    }

    @IBAction func search(_ sender: Any) {
        performSegue(withIdentifier: "toSearch", sender: self.parent)
    }

    @IBAction func create(_ sender: UIButton) {
        performSegue(withIdentifier: "toCreate", sender: self)
    }
    
    @IBAction func profile(_ sender: UIButton) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @IBAction func listings(_ sender: UIButton) {
        performSegue(withIdentifier: "toListings", sender: self)
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        super.saveThenSignOff()
        performSegue(withIdentifier: "toMain", sender: self)
    }

}
