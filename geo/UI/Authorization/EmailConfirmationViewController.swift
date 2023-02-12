//
//  EmailConfirmationViewController.swift
//  geo
//
//  Created by Andrey on 08.02.2023.
//

import UIKit

class EmailConfirmationViewController: UIViewController, NotificatingViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    var signupResponse: AuthorizationService.SignupResponse?
    var email: String?
    var successCompletion: ((String) -> Void)?
    var code: Int? {
        Int(codeTextField.text ?? "")
    }
    
    @IBOutlet private var codeTextField: UITextField!
    
    @IBOutlet private var submitButton: UIButton!
    
    @IBAction private func codeChanged(_ sender: UITextField) {
        verifyCode()
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        guard let code = code, let signupResponse = signupResponse, let email = email else {
            return
        }
        authorizationService.verifyEmail(code: code, signupResponse: signupResponse) { [weak self] result in
            switch result {
            case .success:
                self?.successCompletion?(email)
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func verifyCode() {
        submitButton.isEnabled = String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
}
