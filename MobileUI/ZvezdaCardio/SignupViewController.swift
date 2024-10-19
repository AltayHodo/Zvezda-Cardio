//
//  SignupViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 18/10/24.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        error.alpha = 0
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        
    }
    
    @IBAction func loginTransition(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
