//
//  SettingsSwitchEntry.swift
//  geo
//
//  Created by Andrey on 08.04.2023.
//

import UIKit

typealias SwitchHandler = (Bool) -> Void
typealias SwitchUpdater = () -> Bool

struct SettingsSwitchEntry: SettingsEntry {
    var title: String
    var switchHandler: SwitchHandler
    var switchUpdater: SwitchUpdater
    
    let action: (() -> Void)? = nil
    let accessoryType: UITableViewCell.AccessoryType = .none
}
