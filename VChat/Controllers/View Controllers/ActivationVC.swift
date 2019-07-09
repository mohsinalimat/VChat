//
//  ActivationVC.swift
//  VChat
//
//  Created by Hesham Salama on 7/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ActivationVC: UIViewController {
    
    private let segueID = "gotochats"
    private var lastTimeVerificationSent : TimeInterval = 0
    private var hasSentVerificaton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultMaskType(.clear)
        sendEmailVerification()
        registerForegroundNotification()
    }
    
    private func registerForegroundNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification
            , object: nil)
    }
    
    @objc func appMovedToForeground() {
        goToMainIfAccountHasBeenVerified()
    }

    
    private func sendEmailVerification() {
        lastTimeVerificationSent = Date().timeIntervalSince1970
        hasSentVerificaton = false
        FirebaseUser.sendEmailVerification { (error) in
            self.hasSentVerificaton = true
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "Activation Error", content: error!.localizedDescription)
                }
                return
            }
        }
    }
    
    @IBAction func sendVerificationMailButtonClicked(_ sender: UIButton) {
        if Date().timeIntervalSince1970 - lastTimeVerificationSent > 10.0, hasSentVerificaton {
            sendEmailVerification()
        } else {
            print("Nope")
        }
    }
    private func showErrorAlert(title: String, content: String) {
        let alert = Alert.simple(title: title, content: content)
        self.present(alert, animated: true)
    }
    
    private func goToMainIfAccountHasBeenVerified() {
        SVProgressHUD.show(withStatus: "Checking Verification...")
        resetLogin { (isReset) in
            if isReset {
                if FirebaseUser.hasVerifiedAccount {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: self.segueID, sender: self)
                    }
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func resetLogin(completionHandler: @escaping (Bool) -> ()) {
        FirebaseUser.signOut { (error) in
            guard error == nil else {
                completionHandler(false)
                return
            }
            if let email = TemporarySignUpInfo.email, let password = TemporarySignUpInfo.password {
                FirebaseUser.signIn(email: email, password: password, completionHandler: { (error) in
                    guard error == nil else {
                        completionHandler(false)
                        return
                    }
                    completionHandler(true)
                })
            }
        }
    }
}
