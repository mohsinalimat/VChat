//
//  Alert.swift
//  VChat
//
//  Created by Hesham Salama on 7/8/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    static func simple(title: String, content: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        return alert
    }
}
