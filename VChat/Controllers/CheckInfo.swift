//
//  CheckInfo.swift
//  ShopApp
//
//  Created by Hesham Salama on 3/6/19.
//  Copyright © 2019 hesham. All rights reserved.
//

import Foundation

struct UserInputVerification {
    
    enum entryFormError: String {
        case emptyPassword = "No password entered"
        case emptyEmail = "No email entered"
        case emptyNickName = "No name entered"
        case confirmPasswordMismatch = "The passwords don't match"
        case shortPassword = "Password is too short"
        case shortNickName = "Nickname is too short"
        case passwordNotAlphaNumeric = "Password should contain only english alphabet and numbers"
        case nickNameNotAlphaNumeric = "Nickname should contain only english alphabet and numbers"
        case invalidEmail = "Invalid Email"
        case noError
    }
    
    func localCheckLoginInfo(email:String, password: String) throws {
        guard !email.isEmptyString() else {
            throw entryFormError.emptyEmail.rawValue
        }
        guard !password.isEmptyString() else {
            throw entryFormError.emptyPassword.rawValue
        }
        guard password.isAlphanumeric else {
            throw entryFormError.passwordNotAlphaNumeric.rawValue
        }
        guard password.count >= 6 else {
            throw entryFormError.shortPassword.rawValue
        }
        guard email.isEmail() else {
            throw entryFormError.invalidEmail.rawValue
        }
    }
    
    func localCheckSignUpInfo(email: String, password: String, confirmedPassword: String) throws {
        _ = try localCheckLoginInfo(email: email, password: password)
        guard password == confirmedPassword else {
            throw entryFormError.confirmPasswordMismatch.rawValue
        }
    }
    
//    func checkNickname(nickname: String) -> entryFormError {
//        guard !nickname.isEmptyString() else {
//            return .emptyNickName
//        }
//        guard nickName.isAlphanumeric else {
//            return .nickNameNotAlphaNumeric
//        }
//        guard nickName.count >= 3 else {
//            return .shortNickName
//        }
//        return .noError
//    }
}

extension String {
    func isEmail() -> Bool {
        let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
        let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
        return __emailPredicate.evaluate(with: self)
    }
    
    func isEmptyString() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
