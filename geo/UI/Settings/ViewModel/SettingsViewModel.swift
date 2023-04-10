//
//  SettingsViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Swinject
import UIKit

protocol SettingsViewModelDelegate: AnyObject, ErrorHandling {
    func showProfilePictureEdit()
    func resetPassword()
    func startSigningOut()
    func signOut()
    func startDeletingAccount(confirmationHandler: @escaping () -> Void)
}

class SettingsViewModel {
    
    private let authorizationService: AuthorizationService
    private let settingsService: SettingsService
    private weak var delegate: SettingsViewModelDelegate?
    
    private (set) lazy var settingGroups = [
        SettingsGroup(
            headerTitle: "Profile",
            footerTitle: nil,
            entries: [
                SettingsActionEntry(
                    kind: .profilePicture,
                    value: nil,
                    action: { [weak self] in self?.delegate?.showProfilePictureEdit()
                    }
                ),
                SettingsActionEntry(
                    kind: .username,
                    value: { [weak self] in self?.authorizationService.username
                    },
                    action: nil
                ),
                SettingsActionEntry(
                    kind: .email,
                    value: { [weak self] in
                        self?.authorizationService.email
                    },
                    action: nil
                ),
                SettingsActionEntry(
                    kind: .password,
                    value: nil,
                    action: { [weak self] in
                        self?.delegate?.resetPassword()
                    }
                )
            ]
        ),
        SettingsGroup(
            headerTitle: "Power Saving",
            footerTitle: """
When this option is enabled, the app will only monitor significant changes \
to your geolocation in the background to reduce power consumption.
""",
            entries: [
                SettingsSwitchEntry(
                    title: "Save energy in the background",
                    switchHandler: { [weak self] newValue in
                        let locationMode = newValue ? LocationMode.economical : LocationMode.precise
                        self?.settingsService.backgroundLocationMode = locationMode
                    },
                    switchUpdater: { [weak self] in
                        self?.settingsService.backgroundLocationMode ?? .precise == .economical
                    }
                )
            ]
        ),
        SettingsGroup(
            headerTitle: "Danger Zone",
            footerTitle: nil,
            entries: [
                SettingsActionEntry(
                    kind: .signOut,
                    value: nil,
                    action: { [weak self] in
                        self?.delegate?.startSigningOut()
                    }
                ),
                SettingsActionEntry(
                    kind: .deleteAccount,
                    value: nil,
                    action: { [weak self] in
                        self?.deleteAccount()
                    }
                )
            ]
        )
    ]
    
    @Published var loadingInProgress = false
    
    init(delegate: SettingsViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        self.authorizationService = container.resolve(AuthorizationService.self)!
        self.settingsService = container.resolve(SettingsService.self)!
    }
    
    private func deleteAccount() {
        delegate?.startDeletingAccount { [weak self] in
            self?.authorizationService.deleteUser { [weak self] result in
                switch result {
                case .success:
                    self?.authorizationService.signOut()
                    self?.delegate?.signOut()
                case .failure(let error):
                    self?.delegate?.handleError(error: error)
                }
            }
        }
    }
}
