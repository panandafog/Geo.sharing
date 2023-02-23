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
    
    @IBOutlet private var newPasswordTextField: UITextField!
    @IBOutlet private var passwordConfirmationTextField: UITextField!
    @IBOutlet private var codeTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        navigationItem.title = "Confirm password reset"
        isModalInPresentation = true
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
    
    private func bindViewModel() {
        viewModel.$changesAllowed.sink { [weak self] output in
            self?.setTextFields(enabled: output)
        }
        .store(in: &cancellables)
        
        viewModel.$confirmationAllowed.sink { [weak self] output in
            self?.setConfirmation(enabled: output)
        }
        .store(in: &cancellables)
        
        viewModel.$activityInProgress.sink { [weak self] output in
            self?.setActivity(enabled: output)
        }
        .store(in: &cancellables)
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
}

extension ResetPasswordViewController: ResetPasswordViewModelDelegate {
    func handlePasswordResetCompletion() {
        coordinator?.handlePasswordResetCompletion()
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
