//
//  LaunchVC.swift
//  VChat
//
//  Created by Hesham Salama on 7/9/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
    
    // either redirect to main or login
    
    let segueIDStart = "gotostart"
    let segueIDMain = "gotomain"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FirebaseUser.hasVerifiedAccount {
            performSegue(withIdentifier: segueIDMain, sender: self)
        } else {
            FirebaseUser.signOut { (_) in
            }
            performSegue(withIdentifier: segueIDStart, sender: self)
        }
    }
}
