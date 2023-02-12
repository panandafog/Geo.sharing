//
//  RequestError.swift
//  geo
//
//  Created by Andrey on 12.02.2023.
//

import Foundation

enum RequestError: Error {
    case apiError(message: String)
    case parsingResponse
    case userIsNotAuthorized
    case unknown
}

extension RequestError {
    
    var description: String {
        switch self {
        case .apiError(let message):
            return message
        case .parsingResponse:
            return "Could not decode server response"
        case .userIsNotAuthorized:
            return "User is not authorised"
        case .unknown:
            return "Unknown error"
        }
    }
}
