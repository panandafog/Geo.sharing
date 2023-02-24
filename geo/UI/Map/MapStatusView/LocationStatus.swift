//
//  LocationStatus.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

enum LocationStatus: Int {
    case ok
    case notStarted
    case noPermission
    
    static let initial = LocationStatus.notStarted
}

