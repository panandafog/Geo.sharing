//
//  AuthorizationCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol AuthorizationCoordinatorDelegate: AnyObject {
    func handleLoginCompletion(childCoordinator: AuthorizationCoordinator)
}

class AuthorizationCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: AuthorizationCoordinatorDelegate
    
    init(navigationController: UINavigationController, delegate: AuthorizationCoordinatorDelegate) {
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        let vc = LoginViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AuthorizationCoordinator: SignupViewControllerDelegate {
    func showEmailConfirmation(
        signupData: EmailConfirmationViewModel.SignupData
    ) {
        let vc = EmailConfirmationViewController.instantiateFromStoryboard()
        vc.coordinator = self
        vc.setup(signupData: signupData)
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
    
    func showSignUp() {
        let vc = SignupViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func handleLoginCompletion() {
        delegate.handleLoginCompletion(childCoordinator: self)
    }
}

extension AuthorizationCoordinator: BackFromPasswordResetViewControllerDelegate {
    func navigateBackFromPasswordResetVC(childCoordinator: PasswordResetCoordinator) {
        childCoordinator.navigationController.popToRootViewController(animated: true)
        childCoordinators.removeLast()
    }
}

extension AuthorizationCoordinator: EmailConfirmationViewControllerDelegate {
    func returnToLogin(email: String) {
        guard let loginVC = navigationController.viewControllers.first(where: {
            ($0 as? LoginViewController != nil)
        }) as? LoginViewController else {
            return
        }
        loginVC.handleSignupResult(email: email)
        navigationController.popToViewController(loginVC, animated: true)
    }
}
