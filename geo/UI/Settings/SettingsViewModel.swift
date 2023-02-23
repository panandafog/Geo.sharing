//
//  SettingsViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import UIKit

protocol SettingsViewModelDelegate: AnyObject {
    func showProfilePictureEdit()
    func resetPassword()
    func signOut()
}

class SettingsViewModel {
    
    private let authorizationService = AuthorizationService.shared
    private weak var delegate: SettingsViewModelDelegate?
    
    private (set) lazy var settingGroups = [
        SettingsGroup(
            title: "Profile",
            entries: [
                SettingsEntry(
                    kind: .profilePicture,
                    value: nil,
                    action: { [weak self] in self?.delegate?.showProfilePictureEdit() }
                ),
                SettingsEntry(
                    kind: .username,
                    value: { [weak self] in self?.authorizationService.username },
                    action: nil
                ),
                SettingsEntry(
                    kind: .email,
                    value: { [weak self] in self?.authorizationService.email },
                    action: nil
                ),
                SettingsEntry(
                    kind: .password,
                    value: nil,
                    action: { [weak self] in self?.delegate?.resetPassword() }
                ),
                SettingsEntry(
                    kind: .signOut,
                    value: nil,
                    action: { [weak self] in self?.delegate?.signOut() }
                )
            ]
        )
    ]
    
    init(delegate: SettingsViewModelDelegate) {
        self.delegate = delegate
    }
}

extension SettingsViewModel {
    
    struct SettingsGroup {
        let title: String?
        let entries: [SettingsEntry]
    }
    
    struct SettingsEntry {
        let kind: EntryKind
        let value: (() -> String?)?
        let action: (() -> Void)?
    }
    
    enum EntryKind {
        case profilePicture
        case username
        case email
        case password
        case signOut
        
        var title: String {
            switch self {
            case .profilePicture:
                return "Profile picture"
            case .username:
                return "Username"
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .signOut:
                return "Sign out"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .profilePicture:
                return UIImage(systemName: "person.crop.rectangle")
            case .username:
                return UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
            case .email:
                return UIImage(systemName: "envelope")
            case .password:
                return UIImage(systemName: "lock")
            case .signOut:
                return UIImage(systemName: "person.fill.xmark")
            }
        }
        
        var iconColor: UIColor? {
            switch self {
            case .signOut:
                return .systemRed
            default:
                return .tintColor
            }
        }
    }
}
