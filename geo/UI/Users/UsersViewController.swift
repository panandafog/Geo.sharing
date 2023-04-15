//
//  UsersViewController.swift
//  geo
//
//  Created by Andrey on 25.01.2023.
//

import UIKit

protocol UsersViewControllerDelegate: AnyObject {
    func showOnMap(user: User)
    func showNotifications()
}

class UsersViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: UsersViewControllerDelegate?
    
    lazy var viewModel = UsersViewModel(
        reloadTableView: { [weak self] in
            self?.updateTable()
            self?.refreshControl.endRefreshing()
        },
        categoryToShow: { [weak self] in
            self?.categoryToShow ?? .friends
        },
        searchQuery: { [weak self] in
            self?.searchQuery
        },
        showUserOnMap: { [weak self] user in
            self?.coordinator?.showOnMap(user: user)
        },
        errorHandler: { [weak self] error in
            self?.showErrorAlert(error)
        }
    )
    
    private var categoryToShow: UsersViewModel.Category {
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
    
    private let tableBackgroundView: EmptyTableBackgroundView = {
        let backgroundView = EmptyTableBackgroundView()
        return backgroundView
    }()
    
    private lazy var openRequestsItem = UIBarButtonItem(
        title: "Friend requests",
        style: .plain,
        target: self,
        action: #selector(openRequests)
    )
    
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
        setupNavigationItem()
        
        viewModel.reloadTable()
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
    
    private func setupNavigationItem() {
        navigationItem.title = "People"
        navigationItem.rightBarButtonItem = openRequestsItem
    }
    
    private func updateTable() {
        friendsTable.reloadData()
        
        let backgroundViewTitle: String?
        switch categoryToShow {
        case .friends:
            backgroundViewTitle = viewModel.friendshipsData.backgroundViewTitle
        case .usersSearch:
            backgroundViewTitle = viewModel.searchResults.backgroundViewTitle
        }
        
        friendsTable.backgroundView?.isHidden = (backgroundViewTitle == nil)
        tableBackgroundView.setup(title: backgroundViewTitle ?? "")
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.reloadTable()
    }
    
    @objc private func openRequests() {
        coordinator?.showNotifications()
    }
}

extension UsersViewController: UITableViewDelegate {
}

extension UsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableDataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell", for: indexPath) as! UserTableCell
        
        if let cellData = viewModel.getCellData(indexPath: indexPath) {
            cell.setup(viewModel: cellData)
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
        viewModel.reloadTable()
    }
}

extension UsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(String(selectedScope))
    }
}

extension UsersViewModel.FriendshipsData {
    var backgroundViewTitle: String? {
        switch self.resultsType {
        case .common:
            return nil
        case .error:
            return nil
        case .noFriends:
            return "You don't have friends yet"
        case .none:
            return nil
        }
    }
}

extension UsersViewModel.SearchResults {
    var backgroundViewTitle: String? {
        switch self.resultsType {
        case .success:
            return nil
        case .error:
            return nil
        case .usersNotFound:
            return "Users not found"
        case .searchQueryEmpty:
            return "Type username to search"
        case .searchQueryTooShort:
            return "Type username to search"
        case .none:
            return nil
        }
    }
}
