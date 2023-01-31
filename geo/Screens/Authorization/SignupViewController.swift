//
//  SignupViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

class SignupViewController: UIViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var successCompletion: ((String) -> Void)?
    
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
    
    @IBAction func passwordConfirmationChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction func submitButtonTouched(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              password == passwordConfirmTextField.text
        else {
            return
        }
        
        activityIndicator.startAnimating()
        submitButton.isEnabled = false
        
        authorizationService.signup(
            username: username,
            password: password
        ) { [weak self] result in
            
            self?.activityIndicator.stopAnimating()
            self?.submitButton.isEnabled = true
            
            switch result {
            case .success(_):
                self?.successCompletion?(username)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func verifyCreds() {
        let credsAreValid = (usernameTextField.text?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (passwordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && passwordConfirmTextField.text == passwordTextField.text
        
        submitButton.isEnabled = credsAreValid
    }
}

