//
//  ViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 18/10/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func boltClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "clickedStart", sender: self)
    }
}

