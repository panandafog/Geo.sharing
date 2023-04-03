//
//  LocationMode.swift
//  geo
//
//  Created by Andrey on 03.04.2023.
//

enum LocationMode: String {
    case precise
    case economical
    
    static let defaultBackground = LocationMode.economical
}
