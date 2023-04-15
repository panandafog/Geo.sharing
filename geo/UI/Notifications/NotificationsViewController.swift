//
//  NotificationsViewController.swift
//  geo
//
//  Created by Andrey on 30.01.2023.
//

import Combine
import UIKit

class NotificationsViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    private lazy var viewModel = NotificationsViewModel(delegate: self)
    private let refreshControl = UIRefreshControl()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let tableBackgroundView: EmptyTableBackgroundView = {
        let backgroundView = EmptyTableBackgroundView()
        backgroundView.setup(title: "You don't have any friend requests yet")
        return backgroundView
    }()
    
    @IBOutlet private var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        setupTable()
        setupRefreshControl()
        setupStyling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.updateFriendshipRequests()
    }
    
    private func bindViewModel() {
        viewModel.$cells.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTable()
            }
        }
        .store(in: &cancellables)
        
        viewModel.$refreshingCells.sink { [weak self] output in
            if !output {
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
        .store(in: &cancellables)
    }
    
    private func setupTable() {
        table.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = false
        
        table.backgroundView = tableBackgroundView
    }
    
    private func updateTable() {
        table.reloadData()
        table.backgroundView?.isHidden = !viewModel.cells.isEmpty
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    private func setupStyling() {
        navigationItem.title = "Friend requests"
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.updateFriendshipRequests()
    }
}

extension NotificationsViewController: UITableViewDelegate {
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.setup(viewModel: viewModel.cells[indexPath.row])
        return cell
    }
}

extension NotificationsViewController: NotificationsViewModelDelegate {
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
