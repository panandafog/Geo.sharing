//
//  RequestPasswordResetViewController.swift
//  geo
//
//  Created by Andrey on 15.02.2023.
//

import Combine
import UIKit

protocol RequestPasswordReseViewControllerDelegate: AnyObject {
    func confirmPasswordReset()
}

class RequestPasswordResetViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: RequestPasswordReseViewControllerDelegate?
    
    lazy var viewModel = RequestPasswordResetViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        emailTextField.text = viewModel.email
        navigationItem.title = "Reset password"
        isModalInPresentation = true
    }
    
    @IBAction private func emailChanged(_ sender: UITextField) {
        viewModel.email = emailTextField.text
    }
    
    @IBAction private func confirmationButtonTouched(_ sender: UIButton) {
        viewModel.confirmResetPassword()
    }
    
    private func bindViewModel() {
        viewModel.$changesAllowed.sink { [weak self] output in
            self?.emailTextField.isEnabled = output
        }
        .store(in: &cancellables)
        
        viewModel.$confirmationAllowed.sink { [weak self] output in
            self?.confirmationButton.isEnabled = output
        }
        .store(in: &cancellables)
        
        viewModel.$activityInProgress.sink { [weak self] output in
            self?.setActivity(enabled: output)
        }
        .store(in: &cancellables)
    }
    
    private func setActivity(enabled: Bool) {
        if enabled {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension RequestPasswordResetViewController: RequestPasswordResetViewModelDelegate {
    func handlePasswordResetConfirmation() {
        coordinator?.confirmPasswordReset()
    }
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
