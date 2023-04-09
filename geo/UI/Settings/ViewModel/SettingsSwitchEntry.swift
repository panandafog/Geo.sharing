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
    let action: (() -> Void)? = nil
    var title: String
    var switchHandler: SwitchHandler
    var switchUpdater: SwitchUpdater
}
