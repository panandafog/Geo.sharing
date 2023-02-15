//
//  RequestPasswordResetViewController.swift
//  geo
//
//  Created by Andrey on 15.02.2023.
//

import UIKit

class RequestPasswordResetViewController: UIViewController, NotificatingViewController {
    
    private let authorizationService = AuthorizationService.shared
    
    var successCompletion: (() -> Void)?
    
    private lazy var resetPasswordViewController: ResetPasswordViewController = {
        let vc = UIViewController.instantiate(name: "ResetPasswordViewController") as! ResetPasswordViewController
        vc.successCompletion = self.successCompletion
        return vc
    }()
    
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = authorizationService.email
        navigationItem.title = "Reset password"
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
                    self?.navigationController?.pushViewController(
                        self!.resetPasswordViewController,
                        animated: true
                    )
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
