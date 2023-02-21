//
//  SignupViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

protocol SignupViewControllerDelegate: AnyObject {
    func showEmailConfirmation(signupData: EmailConfirmationViewController.SignupData)
}

class SignupViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: SignupViewControllerDelegate?
    
    private let authorizationService = AuthorizationService.shared
    
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordConfirmTextField: UITextField!
    
    @IBOutlet private var submitButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.stopAnimating()
        navigationItem.title = "SignUp"
        isModalInPresentation = true
    }
    
    @IBAction private func usernameChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func emailChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func passwordConfirmationChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              password == passwordConfirmTextField.text
        else {
            return
        }
        
        activityIndicator.startAnimating()
        setControls(enabled: false)
        
        authorizationService.signup(
            username: username,
            email: email,
            password: password
        ) { [weak self] result in
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.setControls(enabled: true)
            }
            
            switch result {
            case .success(let signupResponse):
                DispatchQueue.main.async {
                    self?.coordinator?.showEmailConfirmation(
                        signupData: .init(
                            email: email,
                            signupResponse: signupResponse
                        )
                    )
                }
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func verifyCreds() {
        submitButton.isEnabled = (usernameTextField.text?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (passwordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && passwordConfirmTextField.text == passwordTextField.text
        && (emailTextField.text?.isValidEmailAddress ?? false)
    }
    
    private func setControls(enabled: Bool) {
        submitButton.isEnabled = enabled
        usernameTextField.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        passwordConfirmTextField.isEnabled = enabled
    }
}
