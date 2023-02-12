//
//  NotificatingViewController.swift
//  geo
//
//  Created by Andrey on 12.02.2023.
//

import NotificationBannerSwift
import UIKit

protocol NotificatingViewController: UIViewController { }

extension NotificatingViewController {
    
    func showErrorAlert(_ error: RequestError, title: String = "Error") {
        let banner = NotificationBanner(title: title, subtitle: error.description, style: .danger)
        banner.show()
    }
}
