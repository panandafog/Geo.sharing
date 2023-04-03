//
//  SettingsSwitcherCell.swift
//  geo
//
//  Created by Andrey on 03.04.2023.
//

import UIKit

class SettingsSwitcherCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    func setup() {
        titleLabel.text = "test"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        titleLabel.text = nil
    }
}
