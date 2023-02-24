//
//  UITextField+Extensions.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

import UIKit

extension UITextField {
    func set(style: Style) {
        switch style {
        case .common:
            self.layer.borderColor = UIColor.systemGray5.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 5
        case .invalidInput:
            self.layer.borderColor = UIColor.systemRed.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 5
        }
    }
}

extension UITextField {
    
    enum Style {
        case common
        case invalidInput
    }
}
