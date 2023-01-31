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
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
