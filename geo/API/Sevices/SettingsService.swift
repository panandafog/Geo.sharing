//
//  SettingsService.swift
//  geo
//
//  Created by Andrey on 03.04.2023.
//

import Combine
import Foundation

class SettingsService {
    private let defaults = UserDefaults.standard
    
    private let backgroundLocationModeKey = "backgroundLocationMode"
    
    @Published private (set) var currentLocationMode = LocationMode.defaultBackground
    
    @Published private (set) var foregroundLocationMode = LocationMode.precise
    
    @Published var backgroundLocationMode: LocationMode {
        didSet {
            defaults.set(
                backgroundLocationMode.rawValue,
                forKey: backgroundLocationModeKey
            )
        }
    }
    
    var locationModeKind: LocationModeKind = .background {
        didSet {
            switch locationModeKind {
            case .foreground:
                currentLocationMode = foregroundLocationMode
            case .background:
                currentLocationMode = backgroundLocationMode
            }
        }
    }
    
    init() {
        var locationMode: LocationMode?
        if let defaultsString = defaults.string(forKey: backgroundLocationModeKey) {
            locationMode = LocationMode(rawValue: defaultsString)
        }
        backgroundLocationMode = locationMode ?? .defaultBackground
    }
}

extension SettingsService {
    
    enum LocationModeKind {
        case background
        case foreground
    }
}
