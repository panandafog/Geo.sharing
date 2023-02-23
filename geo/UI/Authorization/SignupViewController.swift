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
    
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordConfirmTextField: UITextField!
    
    @IBOutlet private var submitButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        activityIndicator.stopAnimating()
        navigationItem.title = "SignUp"
        isModalInPresentation = true
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
