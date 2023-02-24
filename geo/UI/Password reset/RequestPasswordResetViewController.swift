//
//  RequestPasswordResetViewController.swift
//  geo
//
//  Created by Andrey on 15.02.2023.
//

import Combine
import UIKit

protocol RequestPasswordReseViewControllerDelegate: AnyObject {
    func confirmPasswordReset(email: String)
}

class RequestPasswordResetViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: RequestPasswordReseViewControllerDelegate?
    
    lazy var viewModel = RequestPasswordResetViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var invalidInputTimer: Timer?
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var inputErrorLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
        
        viewModel.setInitialInput()
        emailTextField.text = viewModel.email
    }
    
    @IBAction private func emailChanged(_ sender: UITextField) {
        viewModel.email = emailTextField.text
    }
    
    @IBAction private func confirmationButtonTouched(_ sender: UIButton) {
        viewModel.confirmResetPassword()
    }
    
    private func bindViewModel() {
        viewModel.$changesAllowed.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.emailTextField.isEnabled = output
            }
        }
        .store(in: &cancellables)
        
        viewModel.$confirmationAllowed.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.confirmationButton.isEnabled = output
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
        emailTextField.set(style: .common)
        
        navigationItem.title = "Reset password"
        isModalInPresentation = true
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
        _ invalidInputType: RequestPasswordResetViewModel.InvalidInputType?
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
        }
    }
}

extension RequestPasswordResetViewController: RequestPasswordResetViewModelDelegate {
    func handlePasswordResetConfirmation() {
        guard let email = viewModel.email else {
            return
        }
        coordinator?.confirmPasswordReset(email: email)
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}

extension RequestPasswordResetViewModel.InvalidInputType {
    
    var errorMessage: String {
        switch self {
        case .invalidEmail:
            return "Please enter valid email"
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
