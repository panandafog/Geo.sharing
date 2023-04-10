//
//  Endpoints.swift
//  geo
//
//  Created by Andrey on 23.01.2023.
//

import Foundation

enum Endpoints {
    
    private static let baseComponents: URLComponents = {
        var baseComponents = URLComponents()
        
        baseComponents.scheme = "http"
        baseComponents.host = Secrets.host
        baseComponents.port = Secrets.port
        
        return baseComponents
    }()
    
    static let loginComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/login"
        return components
    }()
    
    static let signupComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/signup"
        return components
    }()
    
    static let confirmEmailComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/confirm_email"
        return components
    }()
    
    static let requestPasswordChangeComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/request_password_change"
        return components
    }()
    
    static let confirmPasswordChangeComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/change_password"
        return components
    }()
    
    static let deleteUserComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/delete"
        return components
    }()
    
    static let searchUsersComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/search"
        return components
    }()
    
    static let profilePictureRequestComponents: URLComponents = {
        var components = baseComponents
        components.path = "/user/profile_picture"
        return components
    }()
    
    static let saveLocationComponents: URLComponents = {
        var components = baseComponents
        components.path = "/location/save"
        return components
    }()
    
    static let getFriendsComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friends/get"
        return components
    }()
    
    static let deleteFriendComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friends/delete"
        return components
    }()
    
    static let getIncomingFriendshipRequestsComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/get_incoming_requests"
        return components
    }()
    
    static let getOutgoingFriendshipRequestsComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/get_outgoing_requests"
        return components
    }()
    
    static let acceptFriendshipRequestComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/accept_request"
        return components
    }()
    
    static let rejectFriendshipRequestComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/reject_request"
        return components
    }()
    
    static let createFriendshipRequestComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/create_request"
        return components
    }()
    
    static let deleteFriendshipRequestComponents: URLComponents = {
        var components = baseComponents
        components.path = "/friendship/delete_request"
        return components
    }()
}
