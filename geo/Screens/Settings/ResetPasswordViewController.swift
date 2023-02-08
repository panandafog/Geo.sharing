//
//  ResetPasswordViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    private let authorizationService = AuthorizationService.shared
    private var code: Int? {
        Int(codeTextField.text ?? "")
    }
    
    var successCompletion: (() -> Void)?
    
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var passwordConfirmationTextField: UITextField!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var confirmationButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func passwordChanged(_ sender: UITextField) {
        verifyCreds()
    }
    @IBAction func passwordConfirmationChanged(_ sender: UITextField) {
        verifyCreds()
    }
    @IBAction func codeChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction func confirmationButtonTouched(_ sender: UIButton) {
        confirmChangingPassword()
    }
    
    private func verifyCreds() {
        confirmationButton.isEnabled = (newPasswordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && newPasswordTextField.text == passwordConfirmationTextField.text
        && String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
    
    private func confirmChangingPassword() {
        setControls(enabled: false)
        activityIndicator.startAnimating()
        
        guard let newPassword = newPasswordTextField.text,
              let code = code
        else {
            return
        }
        authorizationService.confirmPasswordChange(code: code, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                self.setControls(enabled: true)
                self.activityIndicator.stopAnimating()
            }
            
            switch result {
            case .success(()):
                self.successCompletion?()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setControls(enabled: Bool) {
        confirmationButton.isEnabled = enabled
        newPasswordTextField.isEnabled = enabled
        passwordConfirmationTextField.isEnabled = enabled
        codeTextField.isEnabled = enabled
    }
}
