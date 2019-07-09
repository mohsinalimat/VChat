//
//  Register2VC.swift
//  VChat
//
//  Created by Hesham Salama on 7/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

class Register2VC: UIViewController {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var firstNameTextField: UnderlinedTextField!
    @IBOutlet weak var lastNameTextField: UnderlinedTextField!
    @IBOutlet weak var nicknameTextField: UnderlinedTextField!
    @IBOutlet weak var errorLabel: UILabel!
    private let segueID = "gotoactivation"
    private let defaultPictureName = "defaultpfp"
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setTextFieldsLimit()
        self.hideKeyboardWhenTappedAround() 
        SVProgressHUD.setDefaultMaskType(.clear)
    }
    
    fileprivate func requestPhotosPermission(completionHandler: @escaping (Bool) -> ()) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            completionHandler(newStatus ==  PHAuthorizationStatus.authorized ? true : false)
        })
    }
    
    
    func setTextFieldsLimit() {
        firstNameTextField.MAX_TEXT_LENGTH = 20
        lastNameTextField.MAX_TEXT_LENGTH = 20
        nicknameTextField.MAX_TEXT_LENGTH = 15
    }
    
    
    @IBAction func profileImageButtonClicked(_ sender: UIButton) {
        let authStatus = getPhotosAuthStatus()
        switch authStatus {
        case .authorized:
            presentImagePicker()
        case .notDetermined:
            requestPhotosPermission { (isGranted) in
                if isGranted {
                    DispatchQueue.main.async {
                        self.presentImagePicker()
                    }
                } else {
                    print("Permission hasn't been granted")
                }
            }
        default:
            print("Permission hasn't been granted")
        }
    }
    
    fileprivate func presentImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func getPhotosAuthStatus() -> PHAuthorizationStatus {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        return photoAuthorizationStatus
    }
    
    fileprivate func registerUserAndRedirect() {
        setTemporaryData()
        SVProgressHUD.show(withStatus: "Registering...")
        registerUser { (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    self.displaySimpleAlert(title: "Error in registering", content: error!.localizedDescription)
                }
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.segueID, sender: self)
            }
        }
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if areUserInputsValid() {
            checkDuplicateNicknameAndRegisterIfNot()
        }
    }
    
    fileprivate func checkDuplicateNicknameAndRegisterIfNot() {
        SVProgressHUD.show()
        FBDatabaseManager.shared.doesNicknameExist(nickname: nicknameTextField.text!) { [weak self](doesExist) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            guard let self = self else { return }
            if doesExist {
                DispatchQueue.main.async {
                    self.setErrorLabel(errorText: "This nickname has already been registered")
                }
            } else {
                DispatchQueue.main.async {
                    self.registerUserAndRedirect()
                }
            }
        }
    }
    
    private func displaySimpleAlert(title: String, content: String) {
        let alert = Alert.simple(title: title, content: content)
        self.present(alert, animated: true)
    }
    
    private func registerUser(completionHandler: @escaping (Error?) -> ()) {
        if let email = TemporarySignUpInfo.email, let password = TemporarySignUpInfo.password {
            FirebaseUser.signUp(email: email, password: password) { (error) in
                if let error = error {
                    completionHandler(error)
                } else {
                    if let firstName = TemporarySignUpInfo.firstName, let lastName = TemporarySignUpInfo.lastName,
                        let nickName = TemporarySignUpInfo.nickname {
                        FBDatabaseManager.shared.saveCustomerFirstSignUpInfo(email: email, firstName: firstName, lastName: lastName, nickname: nickName, profilePicture: TemporarySignUpInfo.profilePicture, completionHandler: { (error) in
                            completionHandler(error)
                        })
                    }
                    
                }
            }
        } else {
            completionHandler("Null email and password fields...")
        }
    }
    
    fileprivate func areUserInputsValid() -> Bool {
        do {
            if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let nickname = nicknameTextField.text {
                try UserInputVerification.localCheckNames(nickname: nickname, firstName: firstName, lastName: lastName)
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
    
    private func setTemporaryData() {
        TemporarySignUpInfo.firstName = firstNameTextField.text
        TemporarySignUpInfo.lastName = lastNameTextField.text
        TemporarySignUpInfo.nickname = nicknameTextField.text
        if let currentProfilePic = profilePictureButton.currentImage, let defaultPic = UIImage(named: defaultPictureName) {
            TemporarySignUpInfo.profilePicture = currentProfilePic.isEqualToImage(image: defaultPic) ? nil : profilePictureButton.currentImage
        }
    }
}

extension Register2VC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true) {
            self.profilePictureButton.setImage(chosenImage, for: UIControl.State.normal)
        }
    }
}

extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        return self.pngData() == image.pngData()
    }
}
