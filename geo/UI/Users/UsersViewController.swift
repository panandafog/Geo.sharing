//
//  UsersViewController.swift
//  geo
//
//  Created by Andrey on 25.01.2023.
//

import UIKit

protocol UsersViewControllerDelegate: AnyObject {
    func showOnMap(user: User)
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
    
    private func setupStyling() {
        navigationItem.title = "People"
    }
    
    private func updateTable() {
        friendsTable.reloadData()
        friendsTable.backgroundView?.isHidden = viewModel.tableDataCount > 0
        tableBackgroundView.setup(title: tableBackgroundViewTitle)
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.reloadTable()
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
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        guard let bar = searchController.searchBar.text, let scope = searchBar.scopeButtonTitles?[selectedScope]  else { return }
//        filterContentForSearchText(bar, scope: scope)
//    }
}
