//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

public protocol LoginViewControllerDelegate: AnyObject {
    func resetPassword()
    func showSignUp()
    func handleLoginCompletion()
}

class LoginViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: LoginViewControllerDelegate?
    
    private let authorizationService = AuthorizationService.shared
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var resetPasswordButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "LogIn"
        navigationController?.navigationBar.prefersLargeTitles = true
        isModalInPresentation = true
        
        activityIndicator.stopAnimating()
        submitButton.isEnabled = false
    }
    
    @IBAction private func usernameChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        logIn()
    }
    
    @IBAction private func signupButtonTouched(_ sender: UIButton) {
        signUp()
    }
    
    @IBAction private func resetPasswordButtonTouched(_ sender: UIButton) {
        coordinator?.resetPassword()
    }
    
    func handleSignupResult(email: String) {
        emailTextField.text = email
    }
    
    private func verifyCreds() {
        submitButton.isEnabled = (emailTextField.text?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (passwordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && (emailTextField.text?.isValidEmailAddress ?? false)
    }
    
    private func logIn() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        activityIndicator.startAnimating()
        setControls(enabled: false)
        
        authorizationService.login(
            email: email,
            password: password
        ) { [weak self] result in
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.setControls(enabled: true)
            }
            
            switch result {
            case .success:
                self?.coordinator?.handleLoginCompletion()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func signUp() {
        coordinator?.showSignUp()
    }
    
    private func setControls(enabled: Bool) {
        submitButton.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        createAccountButton.isEnabled = enabled
        resetPasswordButton.isEnabled = enabled
    }
}
