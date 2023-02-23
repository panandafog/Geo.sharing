//
//  NotificationsViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Foundation

protocol NotificationsViewModelDelegate: AnyObject {
    func handleError(error: RequestError)
}

class NotificationsViewModel {
    
    private let friendsService = FriendsService.self
    private weak var delegate: NotificationsViewModelDelegate?
    
    @Published var cells = [NotificationCellViewModel]()
    @Published var refreshingCells = false
    
    init(delegate: NotificationsViewModelDelegate) {
        self.delegate = delegate
    }
    
    func updateFriendshipRequests() {
        refreshingCells = true
        friendsService.getFriendshipRequests(type: .incoming) { [weak self] result in
            self?.refreshingCells = false
            switch result {
            case .success(let friendshipRequests):
                self?.cells = friendshipRequests.map { request in
                    NotificationCellViewModel(
                        notification: request,
                        decisionHandler: { accepted in
                            self?.friendsService.answerOnFriendshipRequest(
                                senderID: request.sender.id,
                                accept: accepted
                            ) { result in
                                switch result {
                                case .success:
                                    break
                                case .failure(let error):
                                    self?.delegate?.handleError(error: error)
                                }
                                self?.updateFriendshipRequests()
                            }
                        }
                    )
                }
                
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
