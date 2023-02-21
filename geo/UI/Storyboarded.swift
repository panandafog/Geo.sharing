//
//  Storyboarded.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol Storyboarded {
    static func instantiateFromStoryboard() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiateFromStoryboard() -> Self {
        let name = String(describing: Self.self)
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: name) as! Self
    }
}
