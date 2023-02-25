//
//  AuthorizingService.swift
//  geo
//
//  Created by Andrey on 25.02.2023.
//

import Alamofire
import Foundation

protocol AuthorizingService {
    var authorizationService: AuthorizationService { get }
}

extension AuthorizingService where Self: SendingRequestsService {
    var authorizationHeader: HTTPHeader? {
        guard let token = authorizationService.token else { return nil }
        return makeAuthorizationHeader(token: token)
    }
}
