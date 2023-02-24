//
//  UITextField+Extensions.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

import UIKit

extension UITextField {
    func setHighlighted(style: HighlightingStyle) {
        switch style {
        case .common:
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
        case .invalidInput:
            self.layer.borderColor = UIColor.systemRed.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 5
        }
    }
}

extension UITextField {
    
    enum HighlightingStyle {
        case common
        case invalidInput
    }
}
