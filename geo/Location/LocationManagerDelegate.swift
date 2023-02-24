//
//  LocationManagerDelegate.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

import UIKit

protocol LocationManagerDelegate: AnyObject {
    func openLocationSettings()
}

extension LocationManagerDelegate where Self: UIViewController {
    func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl)
        else {
            return
        }
        
        let alertController = UIAlertController(
            title: "Open settings",
            message: "Open settings to enable geolocation access?",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "Open", style: .default) { _ in
            UIApplication.shared.open(settingsUrl)
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
