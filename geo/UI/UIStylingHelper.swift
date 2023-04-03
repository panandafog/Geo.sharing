//
//  UIStylingHelper.swift
//  geo
//
//  Created by Andrey on 03.04.2023.
//

import UIKit

enum UIStylingHelper {
    
    private static let enabledLocationButtonConfiguration: UIButton.Configuration = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "location.fill")
        configuration.baseBackgroundColor = .tintColor
        configuration.baseForegroundColor = .secondarySystemBackground
        return configuration
    }()
    
    private static let disabledLocationButtonConfiguration: UIButton.Configuration = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "location.fill")
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.baseForegroundColor = .tintColor
        return configuration
    }()
    
    static func makeMapButton(_ button: UIButton) {
        button.backgroundColor = .secondarySystemBackground
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 5.0
        button.layer.cornerRadius = 5.0
    }
    
    static func locationButtonConfiguration(enabled: Bool) -> UIButton.Configuration {
        if enabled {
            return enabledLocationButtonConfiguration
        } else {
            return disabledLocationButtonConfiguration
        }
    }
}
