//
//  FirebaseManager.swift
//  VChat
//
//  Created by Hesham Salama on 7/6/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FBDatabaseManager {
    
    private let USERS_ROOT_KEY = "Users"
    private let NICKNAME_KEY = "nickname"
    private let FIRST_NAME_KEY = "first_name"
    private let LAST_NAME_KEY = "last_name"
    private let LAST_LOGIN_KEY = "last_login"
    private let REGISTER_TIME_KEY = "register_time"
    private let EMAIL_KEY = "email"
    private let PROFILE_PIC_KEY = "profile_picture"
    private let CHATS_KEY = "chats"
    
    private var userSnapShot : DataSnapshot?
    public static var shared = FBDatabaseManager()
    
    private init() {}
    
    func saveCustomerFirstSignUpInfo(email: String, firstName: String, lastName: String, nickname: String, profilePicture: UIImage?, completionHandler: @escaping (Error?) -> ()) {
        let randomName = randomString(length: 8)
        if let profilePicture = profilePicture {
            uploadImageToFirebase(image: profilePicture, imageName: randomName) { (url) in
                if let url = url {
                    self.setNewUser(email: email, firstName: firstName, lastName: lastName, nickname: nickname, profilePictureLink: url.absoluteString, completionHandler: { (error) in
                        completionHandler(error)
                    })
                } else {
                    completionHandler("Couldn't upload the picture")
                }
            }
        } else {
            self.setNewUser(email: email, firstName: firstName, lastName: lastName, nickname: nickname, profilePictureLink: nil) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                completionHandler(error)
            }
        }
    }
    
    func setLastLogin(email: String, completionHandler: @escaping (Error?) -> ()) {
        retrieveUserDetailsBy(email: email) { [weak self](snapShot) in
            guard let self = self else {
                completionHandler("Lost access to Database instance.")
                return
            }
            if let snapshot = snapShot, let key = self.getMainKey(snapshot: snapshot) {
                self.replaceSnapshot(mainKeyOfSnapshot: key, snapshot: snapshot, keyToBeValueChanged: self.LAST_LOGIN_KEY, changedValue: ServerValue.timestamp(), completionHandler: { (error) in
                    completionHandler(error)
                })
            }
        }
    }
    
    public func retrieveUserDetailsBy(email: String, completionHandler: @escaping (DataSnapshot?) -> ()) {
        getSnapshot(mainKey: USERS_ROOT_KEY, filterBy: EMAIL_KEY, valueOfKey: email) { (snapshot) in
            completionHandler(snapshot)
        }
    }
    
    public func retrieveUserDetailsBy(nickname: String, completionHandler: @escaping (DataSnapshot?) -> ()) {
        getSnapshot(mainKey: USERS_ROOT_KEY, filterBy: NICKNAME_KEY, valueOfKey: nickname) { (snapshot) in
            completionHandler(snapshot)
        }
    }
    
    public func doesEmailExist(email: String, completionHandler: @escaping (Bool) -> ()) {
        retrieveUserDetailsBy(email: email) { [weak self](snapshot) in
            guard let self = self else { return }
            if let snapshot = snapshot {
                completionHandler(!self.isSnapshotNull(snapshot: snapshot))
                return
            }
            completionHandler(false)
        }
    }
    
    public func doesNicknameExist(nickname: String, completionHandler: @escaping (Bool) -> ()) {
        retrieveUserDetailsBy(nickname: nickname) { [weak self](snapshot) in
            guard let self = self else { return }
            if let snapshot = snapshot {
                completionHandler(!self.isSnapshotNull(snapshot: snapshot))
                return
            }
            completionHandler(false)
        }
    }
    
    private func isSnapshotNull(snapshot: DataSnapshot) -> Bool {
        if let snapDict = snapshot.value as? [String:AnyObject], snapDict.count > 0 {
            return false
        }
        return true
    }
    
    
    private func setNewUser(email: String, firstName: String, lastName: String, nickname: String, profilePictureLink: String?, completionHandler: @escaping (Error?) -> ()) {
        
        let userRef = Database.database().reference(withPath: USERS_ROOT_KEY)
        let dict : [String : Any?] = [NICKNAME_KEY: nickname, FIRST_NAME_KEY: firstName, LAST_NAME_KEY: lastName, EMAIL_KEY: email, PROFILE_PIC_KEY: profilePictureLink, REGISTER_TIME_KEY: ServerValue.timestamp(), LAST_LOGIN_KEY: ServerValue.timestamp(), CHATS_KEY: nil]
        
        let autoIDRef = userRef.childByAutoId()
        autoIDRef.setValue(dict) { (error, _) in
            completionHandler(error)
        }
    }
    
    private func getSnapshot(mainKey: String, filterBy key: String, valueOfKey: String, completionHandler: @escaping (DataSnapshot?) -> ()) {
        let ref = Database.database().reference(withPath: mainKey)
        ref.queryOrdered(byChild: key).queryEqual(toValue: valueOfKey).observeSingleEvent(of: .value) { (snapshot) in
            completionHandler(snapshot)
        }
    }
    
    private func getMainKey(snapshot: DataSnapshot) -> String? {
        return (snapshot.children.nextObject() as AnyObject).key as String?
    }
    
    private func replaceSnapshot(mainKeyOfSnapshot: String, snapshot: DataSnapshot, keyToBeValueChanged: String, changedValue: Any?, completionHandler: @escaping (Error?) -> ()) {
        snapshot.ref.child(mainKeyOfSnapshot).updateChildValues([keyToBeValueChanged: changedValue ?? ""]) { (error, reference) in
            completionHandler(error)
        }
    }
    
    private func uploadImageToFirebase(image: UIImage, imageName: String, completionHandler: @escaping (URL?) -> ()) {
        let imageName = imageName + ".jpeg"
        let storageRef = Storage.storage().reference().child(imageName)
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("Failed to compress the image")
            completionHandler(nil)
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { url, error in
                    completionHandler(url)
                }
            } else {
                print(error?.localizedDescription ?? "Error in uploading the image")
                completionHandler(nil)
            }
        }
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
