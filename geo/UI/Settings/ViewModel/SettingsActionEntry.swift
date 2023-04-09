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
}

extension SettingsActionEntry {
    
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
