//
//  UsersViewController.swift
//  geo
//
//  Created by Andrey on 25.01.2023.
//

import UIKit

class UsersViewController: UIViewController, NotificatingViewController {
    
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
    
    private var searchQuery: String? {
        if searchController.isActive {
            return searchController.searchBar.text
        } else {
            return nil
        }
    }
    
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    
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
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        friendsTable.refreshControl = refreshControl
    }
    
    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users"
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
                self.friendsTable.reloadData()
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
                self.friendsTable.reloadData()
                self.refreshControl.endRefreshing()
            }
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
            cell.setup(
                friendship: friendships[indexPath.row],
                removeFriendHandler: { [weak self] friendship in
                    self?.removeFriend(friendship: friendship)
                }
            )
        case .usersSearch:
            cell.setup(
                searchedUser: searchResults[indexPath.row],
                addFriendHandler: { [weak self] user in
                    self?.addFriend(user: user)
                },
                removeFriendHandler: { [weak self] friendship in
                    self?.removeFriend(friendship: friendship)
                },
                deleteRequestHandler: { [weak self] friendshipRequest in
                    self?.deleteRequest(friendshipRequest: friendshipRequest)
                }
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
