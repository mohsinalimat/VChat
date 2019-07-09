//
//  UserInputVerification.swift
//  VChat
//
//  Created by Hesham Salama on 7/6/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation

class UserInputVerification {
    
    enum entryFormError: String {
        case emptyPassword = "No password entered"
        case emptyEmail = "No email entered"
        case emptyNickName = "No name entered"
        case confirmPasswordMismatch = "The passwords don't match"
        case shortPassword = "Password is too short"
        case shortNickName = "Nickname is too short"
        case passwordNotAlphaNumeric = "Password should contain only english alphabet and numbers, with no spaces"
        case nickNameNotAlphaNumeric = "Nickname should contain only english alphabet and numbers, with no spaces"
        case invalidEmail = "Invalid Email"
        case emptyFirstName = "No first name entered"
        case emptyLastName = "No last name entered"
        case noError
    }
    
    private static let minimumPasswordCharsCount = 6
    private static let minimumNicknameCharsCount = 4
    
    static func localCheckLoginInfo(email:String, password: String) throws {
        guard !email.isEmptyString() else {
            throw entryFormError.emptyEmail.rawValue
        }
        guard !password.isEmptyString() else {
            throw entryFormError.emptyPassword.rawValue
        }
        guard password.isAlphanumeric else {
            throw entryFormError.passwordNotAlphaNumeric.rawValue
        }
        guard password.count >= minimumPasswordCharsCount else {
            throw entryFormError.shortPassword.rawValue
        }
        guard email.isEmail() else {
            throw entryFormError.invalidEmail.rawValue
        }
    }
    
    static func localCheckSignUpInfo(email: String, password: String, confirmedPassword: String) throws {
        _ = try localCheckLoginInfo(email: email, password: password)
        guard password == confirmedPassword else {
            throw entryFormError.confirmPasswordMismatch.rawValue
        }
    }
    
    static func localCheckNames(nickname: String, firstName: String, lastName: String) throws {
        guard !firstName.isEmptyString() else {
            throw entryFormError.emptyFirstName.rawValue
        }
        guard !lastName.isEmptyString() else {
            throw entryFormError.emptyLastName.rawValue
        }
        _ = try localCheckNickname(nickname: nickname)
    }
    
    private static func localCheckNickname(nickname: String) throws {
        guard !nickname.isEmptyString() else {
            throw entryFormError.emptyNickName.rawValue
        }
        guard nickname.isAlphanumeric else {
            throw entryFormError.nickNameNotAlphaNumeric.rawValue
        }
        guard nickname.count >= minimumNicknameCharsCount else {
            throw entryFormError.shortNickName.rawValue
        }
    }
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
