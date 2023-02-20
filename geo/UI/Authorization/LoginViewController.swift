//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import UIKit

public protocol LoginViewControllerDelegate: class {
    func resetPassword()
    func showSignUp()
}

class LoginViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: LoginViewControllerDelegate?
    
    private let authorizationService = AuthorizationService.shared
    var successCompletion: (() -> Void)?
    var parentNavigationController: UINavigationController?
    
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
        coordinator?.showSignUp()
        
        // TODO: handle success
//        signupViewController.successCompletion = { [weak self] username in
//            DispatchQueue.main.async {
//                if let vc = self {
//                    self?.navigationController?.popToViewController(
//                        vc,
//                        animated: true
//                    )
//                }
//                self?.emailTextField.text = username
//            }
//        }
    }
    
    private func setControls(enabled: Bool) {
        submitButton.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        createAccountButton.isEnabled = enabled
        resetPasswordButton.isEnabled = enabled
    }
}
