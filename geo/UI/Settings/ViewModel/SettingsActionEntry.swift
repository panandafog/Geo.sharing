//
//  SettingsActionEntry.swift
//  geo
//
//  Created by Andrey on 08.04.2023.
//

import UIKit

struct SettingsActionEntry: SettingsEntry {
    let kind: EntryKind
    let value: (() -> String?)?
    let action: (() -> Void)?
    
    var accessoryType: UITableViewCell.AccessoryType {
        kind.accessoryType
    }
}

extension SettingsActionEntry {
    
    enum EntryKind {
        case profilePicture
        case username
        case email
        case password
        case signOut
        case deleteAccount
        
        var title: String {
            switch self {
            case .profilePicture:
                return "Profile picture"
            case .username:
                return "Username"
            case .email:
                return "Email"
            case .password:
                return "Reset password"
            case .signOut:
                return "Sign out"
            case .deleteAccount:
                return "Delete account"
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
            case .deleteAccount:
                return UIImage(systemName: "trash")
            }
        }
        
        var iconColor: UIColor? {
            switch self {
            case .signOut:
                return .systemRed
            case .deleteAccount:
                return .systemRed
            default:
                return .tintColor
            }
        }
        
        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .profilePicture:
                return .disclosureIndicator
            case .username:
                return .none
            case .email:
                return .none
            case .password:
                return .disclosureIndicator
            case .signOut:
                return .none
            case .deleteAccount:
                return .none
            }
        }
    }
}
