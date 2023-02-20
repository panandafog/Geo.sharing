//
//  AuthorizationCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol BackToParentViewControllerDelegate {
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
    
    func showEmailConfirmation() {
        let vc = EmailConfirmationViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
