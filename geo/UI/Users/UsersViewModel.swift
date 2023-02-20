//
//  UsersViewModel.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import Foundation

class UsersViewModel {
    
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private var friendships = [Friendship]()
    private var searchResults = [SearchedUser]()
    
    var reloadTableView: (() -> Void)
    var categoryToShow: (() -> Category)
    var searchQuery: (() -> String?)
    var errorHandler: ((RequestError) -> Void)
    
    var tableDataCount: Int {
        switch categoryToShow() {
        case .friends:
            return friendships.count
        case .usersSearch:
            return searchResults.count
        }
    }
    
    init(
        reloadTableView: @escaping (() -> Void),
        categoryToShow: @escaping (() -> Category),
        searchQuery: @escaping (() -> String?),
        errorHandler: @escaping ((RequestError) -> Void)
    ) {
        self.reloadTableView = reloadTableView
        self.categoryToShow = categoryToShow
        self.searchQuery = searchQuery
        self.errorHandler = errorHandler
    }
    
    func reloadTable() {
        if let searchQuery = searchQuery() {
            reloadSearchResults(query: searchQuery)
        } else {
            reloadFriends()
        }
    }
    
    func getCellData(indexPath: IndexPath) -> UserTableCell.UserTableData? {
        var result: UserTableCell.UserTableData?
        
        switch categoryToShow() {
        case .friends:
            let friendship = friendships[indexPath.row]
            if let user = friendship.user {
                result = .init(
                    user: user,
                    actions: [
                        removeFriendAction(friendship: friendship)
                    ]
                )
            }
        case .usersSearch:
            let searchedUser = searchResults[indexPath.row]
            let user = searchedUser.user
            
            var actions: [UserTableCell.UserAction] = []
            if let friendship = searchedUser.friendship {
                actions.append(removeFriendAction(friendship: friendship))
            } else if let friendshipRequest = searchedUser.friendshipRequest {
                actions.append(deleteRequestAction(friendshipRequest: friendshipRequest))
            } else {
                actions.append(addFriendAction(user: user))
            }
            
            result = .init(
                user: user,
                actions: actions
            )
        }
        return result
    }
    
    private func reloadFriends() {
        usersService.getFriendships { result in
            switch result {
            case .success(let friendships):
                self.friendships = friendships
                
            case .failure(let error):
                self.errorHandler(error)
            }
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
    private func reloadSearchResults(query: String) {
        usersService.searchUsers(username: query) { result in
            switch result {
            case .success(let users):
                self.searchResults = users
                
            case .failure(let error):
                self.errorHandler(error)
            }
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
    private func addFriend(user: User) {
        friendsService.sendFriendshipRequest(recipientID: user.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorHandler(error)
            }
            self.reloadTable()
        }
    }
    
    private func removeFriend(friendship: Friendship) {
        guard let userID = friendship.user?.id else {
            return
        }
        friendsService.deleteFriend(userID: userID) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorHandler(error)
            }
            self.reloadTable()
        }
    }
    
    private func deleteRequest(friendshipRequest: FriendshipRequest) {
        friendsService.deleteFriendshipRequest(recipientID: friendshipRequest.recipient.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorHandler(error)
            }
            self.reloadTable()
        }
    }
    
    private func addFriendAction(user: User) -> UserTableCell.UserAction {
        UserTableCell.UserAction(
            actionType: .addFriend
        ) { [weak self] _ in
            self?.addFriend(user: user)
        }
    }
    
    private func removeFriendAction(friendship: Friendship) -> UserTableCell.UserAction {
        UserTableCell.UserAction(
            actionType: .removeFriend
        ) { [weak self] _ in
            self?.removeFriend(friendship: friendship)
        }
    }
    
    private func deleteRequestAction(friendshipRequest: FriendshipRequest) -> UserTableCell.UserAction {
        UserTableCell.UserAction(
            actionType: .deleteRequest
        ) { [weak self] _ in
            self?.deleteRequest(friendshipRequest: friendshipRequest)
        }
    }
}

extension UsersViewModel {
    enum Category {
        case friends
        case usersSearch
    }
}
