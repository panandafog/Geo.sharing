//
//  EmailConfirmationViewController.swift
//  geo
//
//  Created by Andrey on 08.02.2023.
//

import UIKit

class EmailConfirmationViewController: UIViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    var signupResponse: AuthorizationService.SignupResponse?
    var email: String?
    var successCompletion: ((String) -> Void)?
    var code: Int? {
        Int(codeTextField.text ?? "")
    }
    
    @IBOutlet var codeTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    private func verifyCode() {
        submitButton.isEnabled = (code ?? 0) >= 100000
    }
    
    @IBAction func codeChanged(_ sender: UITextField) {
        verifyCode()
    }
    
    @IBAction func submitButtonTouched(_ sender: UIButton) {
        guard let code = code, let signupResponse = signupResponse, let email = email else {
            return
        }
        authorizationService.verifyEmail(code: code, signupResponse: signupResponse) { [weak self] result in
            switch result {
            case .success():
                self?.successCompletion?(email)
            case .failure(let error):
                print(error)
            }
        }
    }
}
