//
//  Utilities.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 18/10/24.
//

import Foundation
import UIKit

class Utilities {
    
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    static func doPasswordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
}
