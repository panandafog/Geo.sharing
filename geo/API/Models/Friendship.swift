//
//  Friendship.swift
//  geo
//
//  Created by Andrey on 26.01.2023.
//

import Foundation

struct Friendship: Codable {
    let id: String
    let user1, user2: User
    
    var user: User? {
        guard let userID = AuthorizationService.shared.uid else {
            return nil
        }
        
        if userID == user1.id {
            return user2
        } else if userID == user2.id {
            return user1
        } else {
            return nil
        }
    }
}
