//
//  HomeViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 19/10/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    var email: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func statsClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToStats", sender: self)
    }
    
    @IBAction func zvezdaClicked(_ sender: Any) {
    }
    
    @IBAction func startwalkPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToWalk", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToStats" {
            let destinationVC = segue.destination as! StatsViewController
            destinationVC.email = email
        }
    }
}
