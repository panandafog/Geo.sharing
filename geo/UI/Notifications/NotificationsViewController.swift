//
//  NotificationsViewController.swift
//  geo
//
//  Created by Andrey on 30.01.2023.
//

import UIKit

class NotificationsViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: MainCoordinator?
    
    private let friendsService = FriendsService.self
    private var friendshipRequests = [FriendshipRequest]()
    private let refreshControl = UIRefreshControl()
    
    private let tableBackgroundView: EmptyTableBackgroundView = {
        let backgroundView = EmptyTableBackgroundView()
        backgroundView.setup(title: "You don't have any notifications yet")
        return backgroundView
    }()
    
    @IBOutlet private var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupRefreshControl()
        setupStyling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateFriendshipRequests()
    }
    
    private func updateFriendshipRequests() {
        friendsService.getFriendshipRequests(type: .incoming) { result in
            switch result {
            case .success(let friendshipRequests):
                self.friendshipRequests = friendshipRequests
                
            case .failure(let error):
                self.showErrorAlert(error)
            }
            DispatchQueue.main.async {
                self.updateTable()
                self.refreshControl.endRefreshing()
            }
        }
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
        table.backgroundView?.isHidden = !friendshipRequests.isEmpty
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.refreshControl = refreshControl
    }
    
    private func setupStyling() {
        navigationItem.title = "Notifications"
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        updateFriendshipRequests()
    }
}

extension NotificationsViewController: UITableViewDelegate {
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendshipRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.setup(
            notification: friendshipRequests[indexPath.row]
        ) { [weak self] request, confirmed in
            self?.friendsService.answerOnFriendshipRequest(
                senderID: request.sender.id,
                accept: confirmed
            ) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.showErrorAlert(error)
                }
                self?.updateFriendshipRequests()
            }
        }
        return cell
    }
}
