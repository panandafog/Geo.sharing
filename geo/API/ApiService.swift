//
//  ApiService.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import Alamofire

protocol ApiService {
    typealias EmptyCompletion = (Result<Void, ApiError>) -> Void
    
    static var authorizationHeader: HTTPHeader? { get }
}

extension ApiService {
    
    static var authorizationHeader: HTTPHeader? {
        guard let token = AuthorizationService.shared.token else {
            return nil
        }
        return .authorization(bearerToken: token)
    }
}
