//
//  UIViewController+Extensions.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

extension UIViewController {
    
    static func instantiate(name: String, storyboardName: String? = nil) -> UIViewController {
        let storyboardName = storyboardName ?? name
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name)
    }
}
