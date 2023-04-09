//
//  SettingsEntry.swift
//  geo
//
//  Created by Andrey on 08.04.2023.
//

import Foundation

protocol SettingsEntry {
    var action: (() -> Void)? { get }
    var isSelectable: Bool { get }
}

extension SettingsEntry {
    
    var isSelectable: Bool {
        action != nil
    }
}
