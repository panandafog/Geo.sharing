//
//  UserTableCell.swift
//  geo
//
//  Created by Andrey on 27.01.2023.
//

import UIKit

class UserTableCell: UITableViewCell {
    
    private var userTableData: UserTableData?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = "..."
        actionButton.menu = nil
    }
    
    func setup(userTableData: UserTableData) {
        self.userTableData = userTableData
        setupLabel(user: userTableData.user)
        setupMenu(userActions: userTableData.actions)
    }
    
    private func setupLabel(user: User) {
        titleLabel.text = user.username
    }
    
    private func setupMenu(userActions: [UserAction]) {
        let uiActions: [UIAction] = userActions.map { userAction in
            UIAction(
                title: userAction.actionType.title,
                image: userAction.actionType.image,
                handler: userAction.action
            )
        }
        
        let menu = UIMenu(options: .displayInline, children: uiActions)
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
    }
}

extension UserTableCell {
    
    struct UserTableData {
        let user: User
        let actions: [UserAction]
    }
    
    struct UserAction {
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
