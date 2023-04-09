//
//  SettingsSwitcherCell.swift
//  geo
//
//  Created by Andrey on 03.04.2023.
//

import UIKit

class SettingsSwitcherCell: UITableViewCell, ReusableView {
    
    private var entry: SettingsSwitchEntry?
    
    @IBOutlet private var uiSwitch: UISwitch!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBAction private func switchValueChanged(_ sender: UISwitch) {
        entry?.switchHandler(sender.isOn)
    }
    
    func setup(_ entry: SettingsSwitchEntry) {
        self.entry = entry
        updateUI()
    }
    
    private func updateUI() {
        titleLabel.text = entry?.title
        uiSwitch.isOn = entry?.switchUpdater() ?? false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
