//
//  EmailConfirmationViewController.swift
//  geo
//
//  Created by Andrey on 08.02.2023.
//

import UIKit

protocol EmailConfirmationViewControllerDelegate: AnyObject {
    func returnToLogin(email: String)
}

class EmailConfirmationViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: EmailConfirmationViewControllerDelegate?
    
    private let authorizationService = AuthorizationService.shared
    
    private var signupData: SignupData?
    var code: Int? {
        Int(codeTextField.text ?? "")
    }
    
    @IBOutlet private var codeTextField: UITextField!
    
    @IBOutlet private var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Confirm email address"
        isModalInPresentation = true
    }
    
    @IBAction private func codeChanged(_ sender: UITextField) {
        verifyCode()
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        guard let code = code,
              let signupResponse = signupData?.signupResponse,
              let email = signupData?.email else {
            return
        }
        authorizationService.verifyEmail(code: code, signupResponse: signupResponse) { [weak self] result in
            switch result {
            case .success:
                self?.coordinator?.returnToLogin(email: email)
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    func setup(signupData: SignupData) {
        self.signupData = signupData
    }
    
    private func verifyCode() {
        submitButton.isEnabled = String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
}

extension EmailConfirmationViewController {
    
    struct SignupData {
        let email: String
        let signupResponse: AuthorizationService.SignupResponse
    }
}
