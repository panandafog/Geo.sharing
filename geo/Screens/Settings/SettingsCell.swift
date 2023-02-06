//
//  SettingsCell.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setup(_ entry: SettingsViewController.SettingsEntry) {
        titleLabel.text = entry.title
        iconImageView.image = entry.image
    }
    
    private func commonInit() {
        accessoryType = .disclosureIndicator
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        iconImageView.image = nil
    }
}
