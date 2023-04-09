//
//  SettingsActionCell.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class SettingsActionCell: UITableViewCell, ReusableView {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    
    func setup(_ entry: SettingsActionEntry) {
        titleLabel.text = entry.kind.title
        valueLabel.text = entry.value?()
        iconImageView.image = entry.kind.image
        iconImageView.tintColor = entry.kind.iconColor
        
        if entry.action != nil {
            accessoryType = .disclosureIndicator
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
        iconImageView.image = nil
        accessoryType = .none
    }
}
