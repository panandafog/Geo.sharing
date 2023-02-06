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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var declineButton: UIButton!
    
    func setup(notification: FriendshipRequest, completion: @escaping ConfirmationCompletion) {
        titleLabel.text = "Friend request from "
        + notification.sender.username
        self.request = notification
        
        self.completion = completion
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
    
    @IBAction func acceptButtonTouched(_ sender: UIButton) {
        guard let request = request else {
            return
        }
        completion?(request, true)
    }
    
    @IBAction func declineButtonTouched(_ sender: UIButton) {
        guard let request = request else {
            return
        }
        completion?(request, false)
    }
}
