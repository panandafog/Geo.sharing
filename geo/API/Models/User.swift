//
//  UserModel.swift
//  geo
//
//  Created by Andrey on 26.01.2023.
//

import Foundation

struct User: Codable {
    let id, username: String
    let latitude, longitude: Double?
    let lastUpdate: String?
    
    var lastUpdateDate: Date? {
        if let lastUpdate = lastUpdate {
            return DateHelper.apiDateFormatter.date(from: lastUpdate)
        }
        return nil
    }
}

extension User {
    enum CodingKeys: String, CodingKey {
        case id, username, latitude, longitude
        case lastUpdate = "last_update"
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
