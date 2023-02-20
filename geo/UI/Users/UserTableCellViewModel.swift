//
//  UserTableCellViewModel.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

struct UserTableCellViewModel {
    let user: User
    let actions: [Action]
}

extension UserTableCellViewModel {
    
    struct Action {
        let actionType: ActionType
        let action: ((UIAction) -> Void)
    }
    
    enum ActionType {
        case addFriend
        case removeFriend
        case deleteRequest
        
        var title: String {
            switch self {
            case .addFriend:
                return "Add friend"
            case .removeFriend:
                return "Remove friend"
            case .deleteRequest:
                return "Delete friend request"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .addFriend:
                return UIImage(systemName: "person.badge.plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
            case .removeFriend:
                return UIImage(systemName: "person.fill.xmark.rtl")?.withTintColor(color, renderingMode: .alwaysOriginal)
            case .deleteRequest:
                return UIImage(systemName: "person.fill.xmark.rtl")?.withTintColor(color, renderingMode: .alwaysOriginal)
            }
        }
        
        var color: UIColor {
            switch self {
            case .addFriend:
                return .tintColor
            case .removeFriend:
                return .systemRed
            case .deleteRequest:
                return .systemRed
            }
        }
    }
}
