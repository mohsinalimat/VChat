//
//  UnderlinedTextField.swift
//  VChat
//
//  Created by Hesham Salama on 7/6/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit

class UnderlinedTextField: UITextField {
    
    var MAX_TEXT_LENGTH = 50
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        borderStyle = .none
        addUnderline()
    }
    
    func addUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addTarget(self, action: #selector(limitLength), for: .editingChanged)
    }
    
    @objc private func limitLength() {
        text = text?.safelyLimitedTo(length: MAX_TEXT_LENGTH)
    }
}
