//
//  PasswordResettingViewController.swift
//  geo
//
//  Created by Andrey on 16.02.2023.
//

import UIKit

protocol PasswordResettingViewController: UIViewController { }

extension PasswordResettingViewController {
    typealias CompletionHandler = (() -> Void)
    
    private func resetPasswordViewController(
        completion: CompletionHandler?
    ) -> RequestPasswordResetViewController {
        let vc = UIViewController.instantiate(name: "RequestPasswordResetViewController") as! RequestPasswordResetViewController
        vc.successCompletion = completion
        return vc
    }
    
    func resetPassword(completion: CompletionHandler? = nil) {
        navigationController?.pushViewController(
            self.resetPasswordViewController(completion: completion),
            animated: true
        )
    }
}
