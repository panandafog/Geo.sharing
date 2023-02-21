//
//  UsersViewModel.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import Foundation

class UsersViewModel {
    
    private static let minQueryLength = 3
    
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private (set) var friendshipsData = FriendshipsData(friendships: [], resultsType: .none)
    private (set) var searchResults = SearchResults(foundUsers: [], resultsType: .none)
    
    var reloadTableView: (() -> Void)
    var categoryToShow: (() -> Category)
    var searchQuery: (() -> String?)
    var showUserOnMap: ((User) -> Void)
    var errorHandler: ((RequestError) -> Void)
    
    var tableDataCount: Int {
        switch categoryToShow() {
        case .friends:
            return friendshipsData.friendships.count
        case .usersSearch:
            return searchResults.foundUsers.count
        }
    }
    
    init(
        reloadTableView: @escaping (() -> Void),
        categoryToShow: @escaping (() -> Category),
        searchQuery: @escaping (() -> String?),
        showUserOnMap: @escaping ((User) -> Void),
        errorHandler: @escaping ((RequestError) -> Void)
    ) {
        self.reloadTableView = reloadTableView
        self.categoryToShow = categoryToShow
        self.searchQuery = searchQuery
        self.showUserOnMap = showUserOnMap
        self.errorHandler = errorHandler
    }
    
    func reloadTable() {
        if let searchQuery = searchQuery() {
            reloadSearchResults(query: searchQuery)
        } else {
            reloadFriends()
        }
    }
    
    func getCellData(indexPath: IndexPath) -> UserTableCellViewModel? {
        var result: UserTableCellViewModel?
        
        switch categoryToShow() {
        case .friends:
            let friendship = friendshipsData.friendships[indexPath.row]
            if let user = friendship.user {
                result = .init(
                    user: user,
                    actions: [
                        showOnMapAction(user: user),
                        removeFriendAction(friendship: friendship)
                    ]
                )
            }
        case .usersSearch:
            let searchedUser = searchResults.foundUsers[indexPath.row]
            let user = searchedUser.user
            
            var actions: [UserTableCellViewModel.Action] = [
                showOnMapAction(user: user)
            ]
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
                self.friendshipsData = FriendshipsData(
                    friendships: friendships,
                    resultsType: friendships.isEmpty ? .noFriends : .common
                )
                
            case .failure(let error):
                self.friendshipsData = FriendshipsData(
                    friendships: [],
                    resultsType: .error
                )
                self.errorHandler(error)
            }
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
    private func reloadSearchResults(query: String) {
        guard query.count >= Self.minQueryLength else {
            searchResults = SearchResults(
                foundUsers: [],
                resultsType: query.isEmpty ? .searchQueryEmpty : .searchQueryTooShort
            )
            DispatchQueue.main.async {
                self.reloadTableView()
            }
            return
        }
        
        usersService.searchUsers(username: query) { [weak self] result in
            switch result {
            case .success(let users):
                self?.searchResults = SearchResults(
                    foundUsers: users,
                    resultsType: users.isEmpty ? .usersNotFound : .success
                )
                
            case .failure(let error):
                self?.searchResults = SearchResults(foundUsers: [], resultsType: .error)
                self?.errorHandler(error)
            }
            DispatchQueue.main.async {
                self?.reloadTableView()
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
    
    private func addFriendAction(user: User) -> UserTableCellViewModel.Action {
        UserTableCellViewModel.Action(
            actionType: .addFriend
        ) { [weak self] _ in
            self?.addFriend(user: user)
        }
    }
    
    private func showOnMapAction(user: User) -> UserTableCellViewModel.Action {
        UserTableCellViewModel.Action(
            actionType: .showOnMap
        ) { [weak self] _ in
            self?.showUserOnMap(user)
        }
    }
    
    private func removeFriendAction(friendship: Friendship) -> UserTableCellViewModel.Action {
        UserTableCellViewModel.Action(
            actionType: .removeFriend
        ) { [weak self] _ in
            self?.removeFriend(friendship: friendship)
        }
    }
    
    private func deleteRequestAction(friendshipRequest: FriendshipRequest) -> UserTableCellViewModel.Action {
        UserTableCellViewModel.Action(
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
  
extension UsersViewModel {
    struct FriendshipsData {
        let friendships: [Friendship]
        let resultsType: FriendsListType?
    }
    
    enum FriendsListType {
        case common
        case error
        case noFriends
    }
}
 
extension UsersViewModel {
    struct SearchResults {
        let foundUsers: [SearchedUser]
        let resultsType: SearchResultsType?
    }
    
    enum SearchResultsType {
        case success
        case error
        case usersNotFound
        case searchQueryEmpty
        case searchQueryTooShort
    }
}
