//
//  LoginViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 18/10/24.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        error.alpha = 0
    }
    
    func validateFields() -> String? {
        // function that checks if all fields are filled while logging in
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill all fields."

        }
        return nil
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        }
        
    }
    @IBAction func signupTransition(_ sender: Any) {
        self.performSegue(withIdentifier: "loginToSignup", sender: self)
    }
    
    func showError(_ message: String) {
        error.text = message
        error.alpha = 1
    }
}
