//
//  ErrorHandling.swift
//  geo
//
//  Created by Andrey on 09.04.2023.
//

import Foundation

protocol ErrorHandling {
    func handleError(error: RequestError)
}

extension ErrorHandling where Self: NotificatingViewController {
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
