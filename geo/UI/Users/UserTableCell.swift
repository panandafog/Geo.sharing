//
//  UserTableCell.swift
//  geo
//
//  Created by Andrey on 27.01.2023.
//

import UIKit

class UserTableCell: UITableViewCell {
    
    typealias AddFriendHandler = ((User) -> Void)
    typealias RemoveFriendHandler = ((Friendship) -> Void)
    typealias DeleteRequestHandler = ((FriendshipRequest) -> Void)
    
    private var addFriendHandler: AddFriendHandler?
    private var removeFriendHandler: RemoveFriendHandler?
    private var deleteRequestHandler: DeleteRequestHandler?
    
    private var searchedUser: SearchedUser?
    private var friendship: Friendship?
    private var actionType: ActionType?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    @IBAction private func actionButtonTouched(_ sender: UIButton) {
        switch actionType {
        case .none:
            break
        case .some(let wrapped):
            switch wrapped {
            case .addFriend:
                guard let user = searchedUser?.user else {
                    break
                }
                addFriendHandler?(user)
            case .removeFriend:
                guard let friendship = friendship ?? searchedUser?.friendship else {
                    break
                }
                removeFriendHandler?(friendship)
            case .deleteRequest:
                guard let friendshipRequest = searchedUser?.friendshipRequest else {
                    break
                }
                deleteRequestHandler?(friendshipRequest)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = "..."
        
        friendship = nil
        searchedUser = nil
        actionType = nil
        
        addFriendHandler = nil
        removeFriendHandler = nil
        deleteRequestHandler = nil
    }
    
    func setup(
        searchedUser: SearchedUser,
        addFriendHandler: @escaping AddFriendHandler,
        removeFriendHandler: @escaping RemoveFriendHandler,
        deleteRequestHandler: @escaping DeleteRequestHandler
    ) {
        self.searchedUser = searchedUser
        self.addFriendHandler = addFriendHandler
        self.removeFriendHandler = removeFriendHandler
        self.deleteRequestHandler = deleteRequestHandler
        
        let action: ActionType
        if searchedUser.friendship != nil {
            action = .removeFriend
        } else if searchedUser.friendshipRequest != nil {
            action = .deleteRequest
        } else {
            action = .addFriend
        }
        
        setup(user: searchedUser.user, action: action)
    }
    
    func setup(friendship: Friendship, removeFriendHandler: @escaping RemoveFriendHandler) {
        self.friendship = friendship
        self.removeFriendHandler = removeFriendHandler
        
        let action = ActionType.removeFriend
        if let user = friendship.user {
            setup(user: user, action: action)
        }
    }
    
    private func setup(user: User, action: ActionType) {
        titleLabel.text = user.username
        
        actionButton.setTitle(action.buttonText, for: .normal)
        actionButton.tintColor = action.buttonColor
        
        self.actionType = action
    }
}

extension UserTableCell {
    enum ActionType {
        case addFriend
        case removeFriend
        case deleteRequest
        
        var buttonText: String {
            switch self {
            case .addFriend:
                return "Add friend"
            case .removeFriend:
                return "Remove friend"
            case .deleteRequest:
                return "Delete friend request"
            }
        }
        
        var buttonColor: UIColor {
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
