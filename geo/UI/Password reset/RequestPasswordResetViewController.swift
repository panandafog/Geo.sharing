//
//  RequestPasswordResetViewController.swift
//  geo
//
//  Created by Andrey on 15.02.2023.
//

import UIKit

public protocol RequestPasswordReseViewControllerDelegate: AnyObject {
    func confirmPasswordReset()
}

class RequestPasswordResetViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    weak var coordinator: RequestPasswordReseViewControllerDelegate?
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = authorizationService.email
        navigationItem.title = "Reset password"
        isModalInPresentation = true
        verifyCreds()
    }
    
    @IBAction private func emailChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func confirmationButtonTouched(_ sender: UIButton) {
        confirmReset()
    }
    
    private func verifyCreds() {
        confirmationButton.isEnabled = emailTextField.text?.isValidEmailAddress ?? false
    }
    
    private func confirmReset() {
        activityIndicator.startAnimating()
        setControls(enabled: false)
        
        authorizationService.requestPasswordChange { [weak self] result in
            DispatchQueue.main.async {
                self?.setControls(enabled: true)
                self?.activityIndicator.stopAnimating()
            }
            
            switch result {
            case .success(()):
                DispatchQueue.main.async {
                    self?.coordinator?.confirmPasswordReset()
                }
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func setControls(enabled: Bool) {
        emailTextField.isEnabled = enabled
        confirmationButton.isEnabled = enabled
    }
}
