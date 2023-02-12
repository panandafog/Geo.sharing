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
