//
//  EmailConfirmationViewController.swift
//  geo
//
//  Created by Andrey on 08.02.2023.
//

import Combine
import UIKit

protocol EmailConfirmationViewControllerDelegate: AnyObject {
    func returnToLogin(email: String)
}

class EmailConfirmationViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: EmailConfirmationViewControllerDelegate?
    
    lazy var viewModel = EmailConfirmationViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var invalidInputTimer: Timer?
    
    @IBOutlet private var codeTextField: UITextField!
    @IBOutlet private var inputErrorLabel: UILabel!
    @IBOutlet private var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
    }
    
    @IBAction private func codeChanged(_ sender: UITextField) {
        viewModel.code = Int(codeTextField.text ?? "")
    }
    
    @IBAction private func submitButtonTouched(_ sender: UIButton) {
        viewModel.verifyEmail()
    }
    
    func setup(signupData: EmailConfirmationViewModel.SignupData) {
        self.viewModel.signupData = signupData
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
        codeTextField.set(style: .common)
        
        navigationItem.title = "Confirm email address"
        isModalInPresentation = true
    }
    
    private func setTextFields(enabled: Bool) {
        codeTextField.isEnabled = enabled
    }
    
    private func setConfirmation(enabled: Bool) {
        submitButton.isEnabled = enabled
    }
    
    private func setActivity(enabled: Bool) {
//        if enabled {
//            activityIndicator.startAnimating()
//        } else {
//            activityIndicator.stopAnimating()
//        }
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
        _ invalidInputType: EmailConfirmationViewModel.InvalidInputType?
    ) {
        let message = invalidInputType?.errorMessage
        
        self.inputErrorLabel.fadeTransition(
            Animations.invalidInputAnimationDuration
        )
        self.inputErrorLabel.text = message
        
        UIView.animate(
            withDuration: Animations.invalidInputAnimationDuration
        ) {
            self.codeTextField.set(
                style: invalidInputType?.codeHighlightStyle ?? .common
            )
        }
    }
}

extension EmailConfirmationViewController: EmailConfirmationViewModelDelegate {
    func handleEmailConfirmation(email: String) {
        coordinator?.returnToLogin(email: email)
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}

extension EmailConfirmationViewModel.InvalidInputType {
    
    var errorMessage: String {
        switch self {
        case .invalidCode:
            return "Code should contain \(String(AuthorizationService.confirmationCodeLength)) digits"
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
