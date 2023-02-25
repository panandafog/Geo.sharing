//
//  Container+Extensions.swift
//  geo
//
//  Created by Andrey on 25.02.2023.
//

import Swinject

extension Container {
    
    static let defaultContainer: Container = {
        let container = Container()
        
        container.register(LocationManager.self) { _ in
            LocationManager()
        }
        
        container.register(LocationService.self) { resolver in
            LocationService(
                authorizationService: resolver.resolve(AuthorizationService.self)!
            )
        }
        container.register(AuthorizationService.self) { _ in
            AuthorizationService()
        }
        container.register(UsersService.self) { resolver in
            UsersService(
                authorizationService: resolver.resolve(AuthorizationService.self)!,
                friendsService: resolver.resolve(FriendsService.self)!
            )
        }
        container.register(FriendsService.self) { resolver in
            FriendsService(
                authorizationService: resolver.resolve(AuthorizationService.self)!
            )
        }
        container.register(ImagesService.self) { resolver in
            ImagesService(
                authorizationService: resolver.resolve(AuthorizationService.self)!
            )
        }
        
        return container
    }()
}
