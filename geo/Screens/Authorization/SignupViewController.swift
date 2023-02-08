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
    @IBOutlet var emailTextField: UITextField!
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
    
    @IBAction func emailChanged(_ sender: UITextField) {
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
              let email = emailTextField.text,
              let password = passwordTextField.text,
              password == passwordConfirmTextField.text
        else {
            return
        }
        
        activityIndicator.startAnimating()
        submitButton.isEnabled = false
        
        authorizationService.signup(
            username: username,
            email: email,
            password: password
        ) { [weak self] result in
            
            self?.activityIndicator.stopAnimating()
            self?.submitButton.isEnabled = true
            
            switch result {
            case .success(let signupResponse):
                DispatchQueue.main.async {
                    let emailConfirmationViewController = UIViewController.instantiate(
                        name: "EmailConfirmationViewController"
                    ) as! EmailConfirmationViewController
                    emailConfirmationViewController.email = email
                    emailConfirmationViewController.signupResponse = signupResponse
                    emailConfirmationViewController.successCompletion = { [weak self] email in
                        emailConfirmationViewController.dismiss(animated: true)
                        self?.successCompletion?(email)
                    }
                    self?.present(emailConfirmationViewController, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func verifyCreds() {
        submitButton.isEnabled = (usernameTextField.text?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (passwordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && passwordConfirmTextField.text == passwordTextField.text
        && (emailTextField.text?.isValidEmailAddress ?? false)
    }
}

