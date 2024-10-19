//
//  SignupViewController.swift
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
class SignupViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        error.alpha = 0
    }
    
    func validateFields() -> String? {
        if name?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            return "Please fill all fields."
        }
        let cleanPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanConfirmPassword = confirmPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanPassword) == false {
            return "Password must contain at least 8 characters, a special character and a number."
        } else if Utilities.doPasswordsMatch(cleanPassword, cleanConfirmPassword) == false {
            return "Passwords do not match."
        }
        return nil
    }
        
    @IBAction func signupPressed(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            // formats the string so that unneccessary spaces before and after it are removed
            let nameOfficial = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailOfficial = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordOffical = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: emailOfficial, password: passwordOffical) { result, err in
                if err != nil {
                    self.error.text = err!.localizedDescription
                    self.error.alpha = 1
                } else {
                    let db = Firestore.firestore()
                    db.collection("User").document(emailOfficial).setData(["name": nameOfficial, "email": emailOfficial, "uid": result!.user.uid])
                    self.error.alpha = 0
                }
                self.dismiss(animated: true)
            }
        }
    }
        
        @IBAction func loginTransition(_ sender: Any) {
            self.dismiss(animated: true)
        }
    
    
    
    
    
    func showError(_ message: String) {
        error.text = message
        error.alpha = 1
    }
    }
