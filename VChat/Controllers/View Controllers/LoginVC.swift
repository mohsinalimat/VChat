//
//  LoginVC.swift
//  VChat
//
//  Created by Hesham Salama on 7/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController {

    let segueIDMain = "gotomain"
    let segueIDActivation = "gotoactivation"
    
    @IBOutlet weak var emailTextField: UnderlinedTextField!
    @IBOutlet weak var passwordTextField: UnderlinedTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setProperitiesOfTextFields()
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    fileprivate func setProperitiesOfTextFields() {
        makePasswordsTextFieldsSecure()
        addClearButtonToTextFields()
        emailTextField.keyboardType = .emailAddress
        emailTextField.becomeFirstResponder()
    }
    
    fileprivate func makePasswordsTextFieldsSecure() {
        passwordTextField.isSecureTextEntry = true
    }
    
    fileprivate func addClearButtonToTextFields() {
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        attemptSigningIn()
    }
    
    fileprivate func attemptSigningIn() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            SVProgressHUD.show(withStatus: "Signing in")
            FirebaseUser.signIn(email: email, password: password) { [weak self](error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                guard let self = self else { return }
                if let error = error {
                    DispatchQueue.main.async {
                        self.setErrorLabel(errorDesc: error.localizedDescription)
                    }
                    return
                }
                self.setLastLogin(email: email)
                DispatchQueue.main.async {
                    self.checkIfVerifiedAndRedirect()
                }
            }
        } else {
            setErrorLabel(errorDesc: "Null login fields")
        }
    }
    
    func checkIfVerifiedAndRedirect() {
        if FirebaseUser.hasVerifiedAccount {
            self.performSegue(withIdentifier: segueIDMain, sender: self)
        } else {
            self.performSegue(withIdentifier: segueIDActivation, sender: self)
        }
    }
    
    private func setLastLogin(email: String) {
        FBDatabaseManager.shared.setLastLogin(email: email, completionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
    private func setErrorLabel(errorDesc: String) {
        errorLabel.text = "Error: \(errorDesc)"
    }
}
