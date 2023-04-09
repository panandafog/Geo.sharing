//
//  SettingsViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Swinject
import UIKit

protocol SettingsViewModelDelegate: AnyObject {
    func showProfilePictureEdit()
    func resetPassword()
    func signOut()
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
                    action: { [weak self] in self?.delegate?.showProfilePictureEdit() }
                ),
                SettingsActionEntry(
                    kind: .username,
                    value: { [weak self] in self?.authorizationService.username },
                    action: nil
                ),
                SettingsActionEntry(
                    kind: .email,
                    value: { [weak self] in self?.authorizationService.email },
                    action: nil
                ),
                SettingsActionEntry(
                    kind: .password,
                    value: nil,
                    action: { [weak self] in self?.delegate?.resetPassword() }
                ),
                SettingsActionEntry(
                    kind: .signOut,
                    value: nil,
                    action: { [weak self] in self?.delegate?.signOut() }
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
        )
    ]
    
    init(delegate: SettingsViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        self.authorizationService = container.resolve(AuthorizationService.self)!
        self.settingsService = container.resolve(SettingsService.self)!
    }
}
