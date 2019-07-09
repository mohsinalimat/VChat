//
//  FirebaseUser.swift
//  VChat
//
//  Created by Hesham Salama on 7/7/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseUser {
    
    static var hasVerifiedAccount: Bool {
        if let user = Auth.auth().currentUser {
            if user.isEmailVerified {
                return true
            }
        }
        return false
    }
    
    static func signUp(email: String, password: String, completionHandler: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            completionHandler(error)
        }
    }
    
    static func signIn(email: String, password: String, completionHandler: @escaping (Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            completionHandler(error)
        }
    }
    
    static func signOut(completionHandler: @escaping (Error?) -> ()) {
        do {
            try Auth.auth().signOut()
            completionHandler(nil)
        }
        catch {
            completionHandler(error)
        }
    }
    
    static func sendEmailVerification(completionHandler: @escaping (Error?) -> ()) {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            completionHandler(error)
        })
    }
}
