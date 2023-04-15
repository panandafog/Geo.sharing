//
//  MainCoordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import Combine
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    lazy var usersVC = UsersViewController.instantiateFromStoryboard()
    lazy var notificationsVC = NotificationsViewController.instantiateFromStoryboard()
    lazy var settingsVC = SettingsViewController.instantiateFromStoryboard()
    
    private let authorizationService: AuthorizationService
    private var rootVC: MapViewController? {
        navigationController.viewControllers.first {
            $0 as? MapViewController != nil
        } as? MapViewController
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(navigationController: UINavigationController, authorizationService: AuthorizationService) {
        self.navigationController = navigationController
        self.authorizationService = authorizationService
    }
    
    func start() {
        let vc = MapViewController.instantiateFromStoryboard()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
        
        authorizationService.objectWillChange.sink { [weak self] _ in
            self?.signOut()
        }
        .store(in: &cancellables)
    }
}

extension MainCoordinator: AuthorizationCoordinatorDelegate {
    func handleLoginCompletion(childCoordinator: AuthorizationCoordinator) {
        childCoordinator.navigationController.dismiss(animated: true)
        childCoordinators.removeLast()
        
        guard let rootVC = rootVC else {
            return
        }
        rootVC.handleLoginCompletion()
    }
}

extension MainCoordinator: MapViewControllerDelegate {
    func showFriends() {
        usersVC.coordinator = self
        navigationController.pushViewController(usersVC, animated: true)
    }
    
    func showSettings() {
        settingsVC.coordinator = self
        navigationController.pushViewController(settingsVC, animated: true)
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

extension MainCoordinator: SettingsViewControllerDelegate {
    func resetPassword() {
        let passwordResetCoordinator = PasswordResetCoordinator(
            navigationController: navigationController,
            delegate: self
        )
        childCoordinators.append(passwordResetCoordinator)
        passwordResetCoordinator.start()
    }
    
    func showProfilePictureEdit() {
        let vc = ProfilePictureViewController.instantiateFromStoryboard()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func signOut() {
        navigationController.popToRootViewController(animated: true)
        guard let rootVC = rootVC else {
            return
        }
        rootVC.handleSignoutCompletion()
    }
}

extension MainCoordinator: BackFromPasswordResetViewControllerDelegate {
    func navigateBackFromPasswordResetVC(childCoordinator: PasswordResetCoordinator) {
        childCoordinators.removeLast()
        signOut()
    }
}

extension MainCoordinator: UsersViewControllerDelegate {
    func showOnMap(user: User) {
        guard let rootVC = rootVC else {
            return
        }
        navigationController.popToRootViewController(animated: true)
        rootVC.show(user: user)
    }
    
    func showNotifications() {
        navigationController.pushViewController(notificationsVC, animated: true)
    }
}
