//
//  ParameterEncoding.swift
//  geo
//
//  Created by Andrey on 25.02.2023.
//

import Alamofire

enum ParameterEncoding {
    case query
    case jsonBody
    
    var alamofireEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .query:
            return URLEncoding(destination: .queryString)
        case .jsonBody:
            return JSONEncoding.default
        }
    }
}
