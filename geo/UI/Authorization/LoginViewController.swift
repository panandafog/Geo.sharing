//
//  LoginViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Combine
import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func resetPassword()
    func showSignUp()
    func handleLoginCompletion()
}

class LoginViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: LoginViewControllerDelegate?
    
    lazy var viewModel = LoginViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var invalidInputTimer: Timer?
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var submitButton: UIButton!
    @IBOutlet private var createAccountButton: UIButton!
    @IBOutlet private var resetPasswordButton: UIButton!
    
    @IBOutlet private var inputErrorLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
        viewModel.setInitialInput()
        emailTextField.text = viewModel.email
    }
    
    @IBAction private func usernameChanged(_ sender: UITextField) {
        viewModel.email = emailTextField.text
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        viewModel.password = passwordTextField.text
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        viewModel.login()
    }
    
    @IBAction private func signupButtonTouched(_ sender: UIButton) {
        coordinator?.showSignUp()
    }
    
    @IBAction private func resetPasswordButtonTouched(_ sender: UIButton) {
        coordinator?.resetPassword()
    }
    
    func handleSignupResult(email: String) {
        emailTextField.text = email
        viewModel.email = email
    }
    
    private func bindViewModel() {
        viewModel.$changesAllowed.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.setTextFields(enabled: output)
            }
        }
        .store(in: &cancellables)
        
        viewModel.$confirmationAllowed.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.setConfirmation(enabled: output)
            }
        }
        .store(in: &cancellables)
        
        viewModel.$activityInProgress.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.setActivity(enabled: output)
            }
        }
        .store(in: &cancellables)
        
        viewModel.$invalidInput.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.handleInvalidInput()
            }
        }
        .store(in: &cancellables)
    }
    
    private func setupStyling() {
        for textField in [emailTextField, passwordTextField] {
            textField?.set(style: .common)
        }
        
        navigationItem.title = "LogIn"
        navigationController?.navigationBar.prefersLargeTitles = true
        isModalInPresentation = true
        
        activityIndicator.stopAnimating()
        submitButton.isEnabled = false
    }
    
    private func setTextFields(enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
    }
    
    private func setConfirmation(enabled: Bool) {
        submitButton.isEnabled = enabled
    }
    
    private func setActivity(enabled: Bool) {
        if enabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func handleInvalidInput() {
        guard let invalidInputType = viewModel.invalidInput else {
            invalidInputTimer?.invalidate()
            showInvalidInput(nil)
            return
        }
        
        invalidInputTimer?.invalidate()
        invalidInputTimer = Timer.scheduledTimer(
            withTimeInterval: Animations.invalidInputTimerInterval,
            repeats: false
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showInvalidInput(invalidInputType)
            }
        }
    }
    
    private func showInvalidInput(
        _ invalidInputType: LoginViewModel.InvalidInputType?
    ) {
        let message = invalidInputType?.errorMessage
        
        self.inputErrorLabel.fadeTransition(
            Animations.invalidInputAnimationDuration
        )
        self.inputErrorLabel.text = message
        
        UIView.animate(
            withDuration: Animations.invalidInputAnimationDuration
        ) {
            self.emailTextField.set(
                style: invalidInputType?.emailHighlightStyle ?? .common
            )
            self.passwordTextField.set(
                style: invalidInputType?.passwordHighlightStyle ?? .common
            )
        }
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func handleLoginCompletion() {
        coordinator?.handleLoginCompletion()
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}

extension LoginViewModel.InvalidInputType {
    
    var errorMessage: String {
        switch self {
        case .invalidEmail:
            return "Please enter valid email"
        case .tooShortPassword:
            return "Password is too short"
        }
    }
    
    var passwordHighlightStyle: UITextField.Style {
        if self == .tooShortPassword {
            return .invalidInput
        } else {
            return .common
        }
    }
    
    var emailHighlightStyle: UITextField.Style {
        if self == .invalidEmail {
            return .invalidInput
        } else {
            return .common
        }
    }
}
