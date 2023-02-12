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
}

extension ApiService {
    
    private static var successfulStatusCodes: ClosedRange<Int> { 200 ... 299 }
    
    static var authorizationHeader: HTTPHeader? {
        guard let token = AuthorizationService.shared.token else {
            return nil
        }
        return .authorization(bearerToken: token)
    }
    
    static func sendRequest<ResponseBodyType>(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo? = nil, headers: [HTTPHeader] = [], completion: @escaping (Result<ResponseBodyType, RequestError>) -> Void) {
        do {
            try makeRequest(method: method, url: url, requiresAuthorization: requiresAuthorization, parameters: parametersInfo, headers: headers)
                .response { response in
                    var decodedResponse: ResponseBodyType?
                    var decodedError: ErrorResponse?
                    var afError = response.error
                    
                    let mustParseResponseBody: Bool
                    if ResponseBodyType.self is Void.Type {
                        mustParseResponseBody = false
                        decodedResponse = Void() as? ResponseBodyType
                    } else {
                        mustParseResponseBody = true
                    }
                    
                    if let value1 = response.value, let value = value1 {
                        if mustParseResponseBody, let responseBodyDecodable = ResponseBodyType.self as? Decodable.Type {
                            decodedResponse = try? JSONDecoder().decode(
                                responseBodyDecodable,
                                from: value
                            ) as? ResponseBodyType
                        }
                        decodedError = try? JSONDecoder().decode(ErrorResponse.self, from: value)
                    }
                    
                    let statusCode = response.response?.statusCode
                    var statusCodeIsSuccessful = false
                    if let statusCode = statusCode, successfulStatusCodes.contains(statusCode) {
                        statusCodeIsSuccessful = true
                    }
                    
                    if statusCodeIsSuccessful, let decodedResponse = decodedResponse {
                        completion(.success(decodedResponse))
                    } else if statusCodeIsSuccessful, decodedResponse == nil {
                        completion(.failure(.parsingResponse))
                    } else if let decodedError = decodedError {
                        completion(.failure(.apiError(message: decodedError.error)))
                    } else if let afError = afError {
                        completion(.failure(.apiError(message: afError.errorDescription ?? afError.localizedDescription)))
                    } else {
                        completion(.failure(.unknown))
                    }
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
