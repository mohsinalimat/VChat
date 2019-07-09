//
//  AppDelegate.swift
//  VChat
//
//  Created by Hesham Salama on 7/4/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FirebaseUser.signOut { (_) in
            
        }
        return true
    }
}

