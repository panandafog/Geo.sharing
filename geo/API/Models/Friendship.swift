//
//  Friendship.swift
//  geo
//
//  Created by Andrey on 26.01.2023.
//

import Foundation
import Swinject

struct Friendship: Codable {
    let id: String
    let user1, user2: User
    
    func user(container: Container = .defaultContainer) -> User? {
        guard let userID = container.resolve(AuthorizationService.self)?.uid else {
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
