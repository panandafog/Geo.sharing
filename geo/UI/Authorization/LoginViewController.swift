//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

class LoginViewController: UIViewController, NotificatingViewController {
    
    private let authorizationService = AuthorizationService.shared
    var successCompletion: (() -> Void)?
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var createAccountButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self?.successCompletion?()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func signUp() {
        let signupViewController = UIViewController.instantiate(name: "SignupViewController") as! SignupViewController
        
        signupViewController.successCompletion = { [weak self] username in
            signupViewController.dismiss(animated: true)
            DispatchQueue.main.async {
                self?.emailTextField.text = username
            }
        }
        present(signupViewController, animated: true)
    }
    
    private func setControls(enabled: Bool) {
        submitButton.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        createAccountButton.isEnabled = enabled
    }
}
