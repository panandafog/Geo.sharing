//
//  ApiService.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import Alamofire
import Foundation

protocol ApiService {
    typealias EmptyCompletion = (Result<Void, RequestError>) -> Void
    
//    static var authorizationHeader: HTTPHeader? { get }
}

extension ApiService {
    
    static var authorizationHeader: HTTPHeader? {
        guard let token = AuthorizationService.shared.token else {
            return nil
        }
        return .authorization(bearerToken: token)
    }
    
    static func sendRequest<T: Decodable>(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo? = nil, headers: [HTTPHeader] = [], completion: @escaping (Result<T, RequestError>) -> Void) {
        do {
            try makeRequest(method: method, url: url, requiresAuthorization: requiresAuthorization, parameters: parametersInfo, headers: headers)
                .responseDecodable(of: T.self) { response in
                    guard let decodedValue = response.value  else {
                        completion(.failure(.parsingResponse))
                        return
                    }
                    completion(.success(decodedValue))
                }
        } catch let error as RequestError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    static func sendRequest(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo? = nil, headers: [HTTPHeader] = [], completion: @escaping EmptyCompletion) {
        do {
            try makeRequest(method: method, url: url, requiresAuthorization: requiresAuthorization, parameters: parametersInfo, headers: headers)
                .response { response in
                    guard response.value != nil else {
                        completion(.failure(.parsingResponse))
                        return
                    }
                    completion(.success(()))
                }
        } catch let error as RequestError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    private static func makeRequest(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo?, headers: [HTTPHeader]) throws -> DataRequest {
        var headers = headers
        if requiresAuthorization {
            guard let authorizationHeader = authorizationHeader else {
                throw RequestError.userIsNotAuthorized
            }
            headers.append(authorizationHeader)
        }
        return AF.request(
            url,
            method: method,
            parameters: parametersInfo?.parameters,
            encoding: parametersInfo?.encoding.alamofireEncoding ?? URLEncoding.default,
            headers: HTTPHeaders(headers)
        )
    }
}

struct ParametersInfo {
    let parameters: [String: Any]
    let encoding: ParameterEncoding
}

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
