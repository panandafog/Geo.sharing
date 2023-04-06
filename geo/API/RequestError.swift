//
//  RequestError.swift
//  geo
//
//  Created by Andrey on 12.02.2023.
//

import Alamofire
import Foundation

enum RequestError: Error {
    case apiError(message: String)
    case afError(error: AFError)
    case parsingResponse
    case unauthorized
    case unknown
    
    init?(statusCode: Int) {
        switch statusCode {
        case 401:
            self = .unauthorized
        default:
            return nil
        }
    }
}

extension RequestError {
    
    var description: String {
        switch self {
        case .apiError(let message):
            return message
        case .parsingResponse:
            return "Could not decode server response"
        case .unauthorized:
            return "User is not authorised"
        case .unknown:
            return "Unknown error"
        case .afError(let afError):
            return afError.localizedDescription
        }
    }
}
