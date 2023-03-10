//
//  PasswordResetCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol BackFromPasswordResetViewControllerDelegate: AnyObject {
    func navigateBackFromPasswordResetVC(childCoordinator: PasswordResetCoordinator)
}

class PasswordResetCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: BackFromPasswordResetViewControllerDelegate
    
    init(navigationController: UINavigationController, delegate: BackFromPasswordResetViewControllerDelegate) {
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        let vc = RequestPasswordResetViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension PasswordResetCoordinator: RequestPasswordReseViewControllerDelegate {
    func confirmPasswordReset(email: String) {
        let vc = ResetPasswordViewController.instantiateFromStoryboard()
        vc.coordinator = self
        vc.setup(email: email)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension PasswordResetCoordinator: ResetPasswordViewControllerDelegate {
    func handlePasswordResetCompletion() {
        delegate.navigateBackFromPasswordResetVC(childCoordinator: self)
    }
}
