//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    @IBOutlet var usernameTextField: UITextField!
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
        let credsAreValid = (usernameTextField.text?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (passwordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        submitButton.isEnabled = credsAreValid
    }
    
    private func logIn() {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        activityIndicator.startAnimating()
        submitButton.isEnabled = false
        createAccountButton.isEnabled = false
        
        authorizationService.login(
            username: username,
            password: password
        ) { [weak self] result in
            
            self?.activityIndicator.stopAnimating()
            self?.submitButton.isEnabled = true
            self?.createAccountButton.isEnabled = true
            
            switch result {
            case .success(_):
                self?.successCompletion?()
            case .failure(let error):
                print("ERROR")
                print(error.localizedDescription)
            }
        }
    }
    
    private func signUp() {
        let signupViewController = UIViewController.instantiate(name: "SignupViewController") as! SignupViewController
        
        signupViewController.successCompletion = { [weak self] username in
            signupViewController.dismiss(animated: true)
            DispatchQueue.main.async {
                self?.usernameTextField.text = username
            }
        }
        present(signupViewController, animated: true)
    }
}

