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
    
    @IBOutlet private var codeTextField: UITextField!
    
    @IBOutlet private var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        navigationItem.title = "Confirm email address"
        isModalInPresentation = true
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
}

extension EmailConfirmationViewController: EmailConfirmationViewModelDelegate {
    func handleEmailConfirmation(email: String) {
        coordinator?.returnToLogin(email: email)
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
