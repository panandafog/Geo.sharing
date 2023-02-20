//
//  UsersViewController.swift
//  geo
//
//  Created by Andrey on 25.01.2023.
//

import UIKit

class UsersViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private var friendships = [Friendship]()
    private var searchResults = [SearchedUser]()
    
    private var categoryToShow: Category {
        if searchController.isActive {
            return .usersSearch
        } else {
            return .friends
        }
    }
    
    private var tableDataCount: Int {
        switch categoryToShow {
        case .friends:
            return friendships.count
        case .usersSearch:
            return searchResults.count
        }
    }
    
    private var searchQuery: String? {
        if searchController.isActive {
            return searchController.searchBar.text
        } else {
            return nil
        }
    }
    
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableBackgroundView: EmptyTableBackgroundView = {
        let backgroundView = EmptyTableBackgroundView()
        return backgroundView
    }()
    
    private var tableBackgroundViewTitle: String {
        switch categoryToShow {
        case .friends:
            return "You don't have any friends yet"
        case .usersSearch:
            return "No user found with this name"
        }
    }
    
    @IBOutlet private var friendsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupRefreshControl()
        setupSearch()
        setupStyling()
        
        reloadTable()
    }
    
    private func setupTable() {
        friendsTable.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "UserTableCell")
        friendsTable.delegate = self
        friendsTable.dataSource = self
        friendsTable.allowsSelection = false
        friendsTable.backgroundView = tableBackgroundView
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        friendsTable.refreshControl = refreshControl
    }
    
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search users"
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    private func setupStyling() {
        navigationItem.title = "People"
    }
    
    private func reloadTable() {
        if let searchQuery = searchQuery {
            reloadSearchResults(query: searchQuery)
        } else {
            reloadFriends()
        }
    }
    
    private func reloadFriends() {
        usersService.getFriendships { result in
            switch result {
            case .success(let friendships):
                self.friendships = friendships
                
            case .failure(let error):
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.updateTable()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func reloadSearchResults(query: String) {
        usersService.searchUsers(username: query) { result in
            switch result {
            case .success(let users):
                self.searchResults = users
                
            case .failure(let error):
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.updateTable()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func updateTable() {
        friendsTable.reloadData()
        friendsTable.backgroundView?.isHidden = tableDataCount > 0
        tableBackgroundView.setup(title: tableBackgroundViewTitle)
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
    
    private func addFriend(user: User) {
        friendsService.sendFriendshipRequest(recipientID: user.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.reloadTable()
            }
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
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.reloadTable()
            }
        }
    }
    
    private func deleteRequest(friendshipRequest: FriendshipRequest) {
        friendsService.deleteFriendshipRequest(recipientID: friendshipRequest.recipient.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.reloadTable()
            }
        }
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        reloadTable()
    }
}

extension UsersViewController {
    enum Category {
        case friends
        case usersSearch
    }
}

extension UsersViewController: UITableViewDelegate {
}

extension UsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch categoryToShow {
        case .friends:
            return friendships.count
        case .usersSearch:
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableCell
        
        switch categoryToShow {
        case .friends:
            let friendship = friendships[indexPath.row]
            if let user = friendship.user {
                cell.setup(
                    userTableData: .init(
                        user: user,
                        actions: [
                            removeFriendAction(friendship: friendship)
                        ]
                    )
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
            
            cell.setup(
                userTableData: .init(
                    user: user,
                    actions: actions
                )
            )
        }
        return cell
    }
}

extension UsersViewController: UISearchResultsUpdating {
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        reloadTable()
    }
}

extension UsersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        guard let bar = searchController.searchBar.text, let scope = searchBar.scopeButtonTitles?[selectedScope]  else { return }
//        filterContentForSearchText(bar, scope: scope)
//    }
}
