//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var successCompletion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.stopAnimating()
        submitButton.isEnabled = false
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction func passwordChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction func submitButtonTouched(_ sender: UIButton) {
        logIn()
    }
    
    @IBAction func signupButtonTouched(_ sender: UIButton) {
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
            case .success(_):
                self?.successCompletion?()
            case .failure(let error):
                print(error.localizedDescription)
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

