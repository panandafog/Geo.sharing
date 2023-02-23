//
//  NotificationCellViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Foundation

struct NotificationCellViewModel {
    
    typealias DecisionHandler = (Bool) -> Void
    
    let notification: FriendshipRequest
    let decisionHandler: DecisionHandler
}
