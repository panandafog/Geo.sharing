//
//  MainCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MapViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFriends() {
        let vc = UsersViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showNotifications() {
        let vc = NotificationsViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSettings() {
        let vc = SettingsViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAuthorization() {
        let authorizationNavigationController = UINavigationController()
        let authorizationCoordinator = AuthorizationCoordinator(
            navigationController: authorizationNavigationController,
            delegate: self
        )
        childCoordinators.append(authorizationCoordinator)
        
        authorizationCoordinator.start()
        navigationController.present(authorizationNavigationController, animated: true)
    }
}

extension MainCoordinator: BackToParentViewControllerDelegate {
    func navigateBackToParentVC(childCoordinator: AuthorizationCoordinator) {
        childCoordinator.navigationController.dismiss(animated: true)
        childCoordinators.removeLast()
    }
}

extension MainCoordinator: SettingsViewControllerDelegate {
    func resetPassword() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func showProfilePictureEdit() {
        let vc = ProfilePictureViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
