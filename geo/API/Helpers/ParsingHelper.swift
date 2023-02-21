//
//  ParsingHelper.swift
//  geo
//
//  Created by Andrey on 21.02.2023.
//

import Foundation

enum DateHelper {
    
    static let dateFormat = "MM/dd/yyyy, HH:mm:ss"
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}
