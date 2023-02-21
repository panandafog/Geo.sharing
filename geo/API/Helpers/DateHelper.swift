//
//  ParsingHelper.swift
//  geo
//
//  Created by Andrey on 21.02.2023.
//

import Foundation

enum DateHelper {
    
    static let apiDateFormat = "MM/dd/yyyy, HH:mm:ss"
    
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = apiDateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    static let shortDisplayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}
