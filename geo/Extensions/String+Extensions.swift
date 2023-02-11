//
//  String+Extensions.swift
//  geo
//
//  Created by Andrey on 08.02.2023.
//

import Foundation

extension String {
    
    var isValidEmailAddress: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
}
