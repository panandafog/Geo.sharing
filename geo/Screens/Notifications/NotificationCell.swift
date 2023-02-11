//
//  NotificationCell.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    typealias ConfirmationCompletion = (FriendshipRequest, Bool) -> Void
    
    private var completion: ConfirmationCompletion?
    private var request: FriendshipRequest?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var acceptButton: UIButton!
    @IBOutlet private var declineButton: UIButton!
    
    @IBAction private func acceptButtonTouched(_ sender: UIButton) {
        guard let request = request else {
            return
        }
        completion?(request, true)
    }
    
    @IBAction private func declineButtonTouched(_ sender: UIButton) {
        guard let request = request else {
            return
        }
        completion?(request, false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func setup(notification: FriendshipRequest, completion: @escaping ConfirmationCompletion) {
        titleLabel.text = "Friend request from "
        + notification.sender.username
        self.request = notification
        
        self.completion = completion
    }
}
