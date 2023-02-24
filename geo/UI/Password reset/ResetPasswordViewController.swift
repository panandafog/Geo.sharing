//
//  ResetPasswordViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import Combine
import UIKit

protocol ResetPasswordViewControllerDelegate: AnyObject {
    func handlePasswordResetCompletion()
}

class ResetPasswordViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: ResetPasswordViewControllerDelegate?
    
    lazy var viewModel = ResetPasswordViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var invalidInputTimer: Timer?
    
    @IBOutlet private var newPasswordTextField: UITextField!
    @IBOutlet private var passwordConfirmationTextField: UITextField!
    @IBOutlet private var codeTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var inputErrorLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupStyling()
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        viewModel.newPassword = newPasswordTextField.text
    }
    @IBAction private func passwordConfirmationChanged(_ sender: UITextField) {
        viewModel.passwordConfirmation = passwordConfirmationTextField.text
    }
    @IBAction private func codeChanged(_ sender: UITextField) {
        viewModel.code = Int(codeTextField.text ?? "")
    }
    @IBAction private func confirmationButtonTouched(_ sender: UIButton) {
        viewModel.confirmChangingPassword()
    }
    
    func setup(email: String) {
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
        for textField in [newPasswordTextField, passwordConfirmationTextField, codeTextField] {
            textField?.set(style: .common)
        }
        
        navigationItem.title = "Confirm password reset"
        isModalInPresentation = true
    }
    
    private func setTextFields(enabled: Bool) {
        newPasswordTextField.isEnabled = enabled
        passwordConfirmationTextField.isEnabled = enabled
        codeTextField.isEnabled = enabled
    }
    
    private func setConfirmation(enabled: Bool) {
        confirmationButton.isEnabled = enabled
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
        _ invalidInputType: ResetPasswordViewModel.InvalidInputType?
    ) {
        let message = invalidInputType?.errorMessage
        
        self.inputErrorLabel.fadeTransition(
            Animations.invalidInputAnimationDuration
        )
        self.inputErrorLabel.text = message
        
        UIView.animate(
            withDuration: Animations.invalidInputAnimationDuration
        ) {
            self.newPasswordTextField.set(
                style: invalidInputType?.passwordHighlightStyle ?? .common
            )
            self.passwordConfirmationTextField.set(
                style: invalidInputType?.passwordConfirmationHighlightStyle ?? .common
            )
            self.codeTextField.set(
                style: invalidInputType?.codeHighlightStyle ?? .common
            )
        }
    }
}

extension ResetPasswordViewController: ResetPasswordViewModelDelegate {
    func handlePasswordResetCompletion() {
        coordinator?.handlePasswordResetCompletion()
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}

extension ResetPasswordViewModel.InvalidInputType {
    
    var errorMessage: String {
        switch self {
        case .tooShortPassword:
            return "Password is too short"
        case .unmatchingPasswordConfirmation:
            return "Incorrect password confirmation"
        case .invalidCode:
            return "Code should contain \(String(AuthorizationService.confirmationCodeLength)) digits"
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
    
    var codeHighlightStyle: UITextField.Style {
        if self == .invalidCode {
            return .invalidInput
        } else {
            return .common
        }
    }
}
