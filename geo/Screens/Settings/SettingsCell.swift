//
//  SettingsCell.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
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
        titleLabel.text = entry.kind.title
        valueLabel.text = entry.value
        iconImageView.image = entry.kind.image
        iconImageView.tintColor = entry.kind.iconColor
        
        if entry.action != nil {
            accessoryType = .disclosureIndicator
        }
    }
    
    private func commonInit() { }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        valueLabel.text = nil
        iconImageView.image = nil
        accessoryType = .none
    }
}
