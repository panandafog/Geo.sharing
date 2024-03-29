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
        
        container.register(SettingsService.self) { _ in
            SettingsService()
        }
        .inObjectScope(.container)
        
        container.register(AuthorizationService.self) { _ in
            AuthorizationService()
        }
        .inObjectScope(.container)
        
        container.register(LocationService.self) { resolver in
            LocationService(
                authorizationService: resolver.resolve(AuthorizationService.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(LocationManager.self) { resolver in
            LocationManager(
                locationService: resolver.resolve(LocationService.self)!,
                settingsService: resolver.resolve(SettingsService.self)!
            )
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
