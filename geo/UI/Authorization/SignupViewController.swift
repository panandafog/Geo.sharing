//
//  SignupViewController.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Combine
import UIKit

protocol SignupViewControllerDelegate: AnyObject {
    func showEmailConfirmation(signupData: EmailConfirmationViewModel.SignupData)
}

class SignupViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: SignupViewControllerDelegate?
    
    lazy var viewModel = SignupViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var invalidInputTimer: Timer?
    
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordConfirmTextField: UITextField!
    
    @IBOutlet private var inputErrorLabel: UILabel!
    @IBOutlet private var submitButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
    }
    
    @IBAction private func usernameChanged(_ sender: UITextField) {
        viewModel.username = usernameTextField.text
    }
    
    @IBAction private func emailChanged(_ sender: UITextField) {
        viewModel.email = emailTextField.text
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        viewModel.password = passwordTextField.text
    }
    
    @IBAction private func passwordConfirmationChanged(_ sender: UITextField) {
        viewModel.passwordConfirm = passwordConfirmTextField.text
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        viewModel.signup()
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
        for textField in [usernameTextField, emailTextField, passwordTextField, passwordConfirmTextField] {
            textField?.set(style: .common)
        }
        
        activityIndicator.stopAnimating()
        navigationItem.title = "SignUp"
        isModalInPresentation = true
    }
    
    private func setTextFields(enabled: Bool) {
        usernameTextField.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        passwordConfirmTextField.isEnabled = enabled
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
        _ invalidInputType: SignupViewModel.InvalidInputType?
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
            self.usernameTextField.set(
                style: invalidInputType?.usernameHighlightStyle ?? .common
            )
            self.passwordTextField.set(
                style: invalidInputType?.passwordHighlightStyle ?? .common
            )
            self.passwordConfirmTextField.set(
                style: invalidInputType?.passwordConfirmationHighlightStyle ?? .common
            )
        }
    }
}

extension SignupViewController: SignupViewModelDelegate {
    func showEmailConfirmation(
        signupData: EmailConfirmationViewModel.SignupData
    ) {
        coordinator?.showEmailConfirmation(
            signupData: signupData
        )
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}

extension SignupViewModel.InvalidInputType {
    
    var errorMessage: String {
        switch self {
        case .tooShortUsername:
            return "Username is too short"
        case .invalidEmail:
            return "Please enter valid email"
        case .tooShortPassword:
            return "Password is too short"
        case .unmatchingPasswordConfirmation:
            return "Incorrect password confirmation"
        }
    }
    
    var usernameHighlightStyle: UITextField.Style {
        if self == .tooShortUsername {
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
    
    var passwordHighlightStyle: UITextField.Style {
        if self == .tooShortPassword {
            return .invalidInput
        } else {
            return .common
        }
    }
    
    var passwordConfirmationHighlightStyle: UITextField.Style {
        if self == .unmatchingPasswordConfirmation {
            return .invalidInput
        } else {
            return .common
        }
    }
}
