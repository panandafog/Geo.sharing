//
//  ApiError.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import Foundation

enum ApiError: Error {
    case wrongCreds
    case parsingResponse
    case unknown
}
