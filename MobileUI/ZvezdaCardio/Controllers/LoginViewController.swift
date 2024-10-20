//
//  LoginViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 18/10/24.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    var name: String?

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
        
        let emailOfficial = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordOfficial = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: emailOfficial, password: passwordOfficial) { result, error in
            
            if error == nil {
                /* get the user's information from "User" database */
                let db = Firestore.firestore()
                db.collection("User").document(emailOfficial).getDocument { (document, error) in
                    if error == nil {
                        if document != nil && document!.exists {
                            let documentData = document!.data()
                            self.name = (documentData!["name"] as! String)
                            self.performSegue(withIdentifier: "loginToStats", sender: self)
                        }
                        else {
                            self.error.text = error?.localizedDescription
                            self.error.alpha = 1
                        }
                    }
                    else {
                        self.error.text = error?.localizedDescription
                        self.error.alpha = 1
                    }
                }
            }
        }
    }
    @IBAction func signupTransition(_ sender: Any) {
        self.performSegue(withIdentifier: "loginToSignup", sender: self)
    }
    
    func showError(_ message: String) {
        error.text = message
        error.alpha = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToStats" {
            let destinationVC = segue.destination as! StatsViewController
            destinationVC.email = email.text
            destinationVC.name = name
        }
    }
}
