//
//  UserTableCell.swift
//  geo
//
//  Created by Andrey on 27.01.2023.
//

import UIKit

class UserTableCell: UITableViewCell {
    
    private var viewModel: UserTableCellViewModel?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet private var actionButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = "..."
        actionButton.menu = nil
    }
    
    func setup(viewModel: UserTableCellViewModel) {
        self.viewModel = viewModel
        setupLabels(user: viewModel.user)
        setupMenu(userActions: viewModel.actions)
    }
    
    private func setupLabels(user: User) {
        titleLabel.text = user.username
        
        let dateString: String
        if let userDate = user.lastUpdateDate {
            dateString = DateHelper.dateFormatter.string(from: userDate)
        } else {
            dateString = "–"
        }
        subtitleLabel.text = "last seen: " + dateString
    }
    
    private func setupMenu(userActions: [UserTableCellViewModel.Action]) {
        let uiActions: [UIAction] = userActions.map { userAction in
            UIAction(
                title: userAction.actionType.title,
                image: userAction.actionType.image,
                handler: userAction.action
            )
        }
        
        let menu = UIMenu(options: .displayInline, children: uiActions)
        actionButton.menu = menu
        actionButton.showsMenuAsPrimaryAction = true
    }
}
