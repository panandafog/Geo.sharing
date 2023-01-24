//
//  Endpoints.swift
//  geo
//
//  Created by Andrey on 23.01.2023.
//

import Foundation

enum Endpopints {
    
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
    
    static let saveLocationComponents: URLComponents = {
        var components = baseComponents
        components.path = "/location/save"
        return components
    }()
}
