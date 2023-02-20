//
//  AuthorizationCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol BackToParentViewControllerDelegate: AnyObject {
    func navigateBackToParentVC(childCoordinator: AuthorizationCoordinator)
}

class AuthorizationCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: BackToParentViewControllerDelegate
    
    init(navigationController: UINavigationController, delegate: BackToParentViewControllerDelegate) {
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        let vc = LoginViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSignUp() {
        let vc = SignupViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AuthorizationCoordinator: SignupViewControllerDelegate {
    func showEmailConfirmation() {
        let vc = EmailConfirmationViewController.instantiateFromStoryboard()
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AuthorizationCoordinator: LoginViewControllerDelegate {
    func resetPassword() {
        let passwordResetCoordinator = PasswordResetCoordinator(
            navigationController: navigationController,
            delegate: self
        )
        childCoordinators.append(passwordResetCoordinator)
        passwordResetCoordinator.start()
    }
}

extension AuthorizationCoordinator: BackFromPasswordResetViewControllerDelegate {
    func navigateBackFromPasswordResetVC(childCoordinator: PasswordResetCoordinator) {
        childCoordinator.navigationController.popToRootViewController(animated: true)
        childCoordinators.removeLast()
    }
}
