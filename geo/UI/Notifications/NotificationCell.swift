//
//  NotificationCell.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    typealias ConfirmationCompletion = (FriendshipRequest, Bool) -> Void
    
    private var viewModel: NotificationCellViewModel?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var acceptButton: UIButton!
    @IBOutlet private var declineButton: UIButton!
    
    @IBAction private func acceptButtonTouched(_ sender: UIButton) {
        viewModel?.decisionHandler(true)
    }
    
    @IBAction private func declineButtonTouched(_ sender: UIButton) {
        viewModel?.decisionHandler(false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func setup(viewModel: NotificationCellViewModel) {
        self.viewModel = viewModel
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Friend request from "
        + (viewModel?.notification.sender.username ?? "...")
    }
}
