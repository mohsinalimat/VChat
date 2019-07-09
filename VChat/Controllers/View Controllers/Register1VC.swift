//
//  Register1VC.swift
//  VChat
//
//  Created by Hesham Salama on 7/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import SVProgressHUD

class Register1VC: UIViewController {
    
    @IBOutlet weak var passwordTextField: UnderlinedTextField!
    @IBOutlet weak var emailTextField: UnderlinedTextField!
    @IBOutlet weak var repeatedPasswordTextField: UnderlinedTextField!
    @IBOutlet weak var errorLabel: UILabel!
    private let segueID = "gotoregister2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setProperitiesOfTextFields()
    }
    
    fileprivate func setProperitiesOfTextFields() {
        makePasswordsTextFieldsSecure()
        addClearButtonToTextFields()
        emailTextField.keyboardType = .emailAddress
        emailTextField.becomeFirstResponder()
    }
    
    fileprivate func makePasswordsTextFieldsSecure() {
        passwordTextField.isSecureTextEntry = true
        repeatedPasswordTextField.isSecureTextEntry = true
    }
    
    fileprivate func addClearButtonToTextFields() {
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        repeatedPasswordTextField.clearButtonMode = .whileEditing
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        checkInputsAndRedirectIfNeeded()
    }
    
    fileprivate func checkInputsAndRedirectIfNeeded() {
        if areUserInputsValid() {
            SVProgressHUD.show(withStatus: "Please wait..")
            FBDatabaseManager.shared.doesEmailExist(email: emailTextField.text!) { [weak self](doesExist) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                guard let self = self else { return }
                if doesExist {
                    DispatchQueue.main.async {
                        self.setErrorLabel(errorText: "The email has already been registered")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.setTempData()
                        self.performSegue(withIdentifier: self.segueID, sender: self)
                    }
                }
            }
        }
    }
    
    fileprivate func areUserInputsValid() -> Bool {
        do {
            if let email = emailTextField.text, let password = passwordTextField.text, let confirmedPassword = repeatedPasswordTextField.text {
                try UserInputVerification.localCheckSignUpInfo(email: email, password: password, confirmedPassword: confirmedPassword)
            } else {
                setErrorLabel(errorText: "One or more fields are null")
                return false
            }
        } catch let error {
            setErrorLabel(errorText: error.localizedDescription)
            return false
        }
        return true
    }
    
    private func setErrorLabel(errorText: String) {
        errorLabel.text = "Error: " + errorText
    }
    
    private func setTempData() {
        TemporarySignUpInfo.email = emailTextField.text
        TemporarySignUpInfo.password = passwordTextField.text
    }
}
