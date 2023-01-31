//
//  FriendshipRequest.swift
//  geo
//
//  Created by Andrey on 26.01.2023.
//

import Foundation

struct FriendshipRequest: Codable {
    let id: String
    let sender, recipient: User
}
