//
//  SendingRequestsService.swift
//  geo
//
//  Created by Andrey on 25.02.2023.
//

import Alamofire
import Foundation

protocol AuthorizationDelegate: AnyObject {
    var authorizationHeader: HTTPHeader? { get }
    
    func signOut()
}

protocol SendingRequestsService {
    typealias EmptyCompletion = (Result<Void, RequestError>) -> Void
    
    var authorizationDelegate: AuthorizationDelegate? { get }
}

extension SendingRequestsService {
    
    private static var successfulStatusCodes: ClosedRange<Int> { 200 ... 299 }
    
    func makeAuthorizationHeader(token: String) -> HTTPHeader {
        .authorization(bearerToken: token)
    }
    
    func sendRequest<ResponseBodyType>(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo? = nil, headers: [HTTPHeader] = [], completion: @escaping (Result<ResponseBodyType, RequestError>) -> Void) {
        
        func handleError(error: RequestError) {
            switch error {
            case .unauthorized:
                authorizationDelegate?.signOut()
            default:
                break
            }
        }
        
        do {
            try makeRequest(method: method, url: url, requiresAuthorization: requiresAuthorization, parameters: parametersInfo, headers: headers)
                .response { response in
                    handleRequestResult(response: response) { result in
                        let result: Result<ResponseBodyType, RequestError> = result
                        switch result {
                        case .failure(let error):
                            handleError(error: error)
                        default:
                            break
                        }
                        completion(result)
                    }
                }
        } catch let error as RequestError {
            completion(.failure(error))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    private func makeRequest(method: HTTPMethod, url: URL, requiresAuthorization: Bool, parameters parametersInfo: ParametersInfo?, headers: [HTTPHeader]) throws -> DataRequest {
        var headers = headers
        if requiresAuthorization {
            guard let authorizationHeader = authorizationDelegate?.authorizationHeader else {
                throw RequestError.unauthorized
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
    
    private func handleRequestResult<ResponseBodyType>(
        response: AFDataResponse<Data?>,
        completion: @escaping (Result<ResponseBodyType, RequestError>) -> Void
    ) {
        var decodedResponse: ResponseBodyType?
        var decodedError: ErrorResponse?
        var statusCodeError: RequestError?
        
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
        if let statusCode = statusCode {
            statusCodeError = RequestError(statusCode: statusCode)
        }
        var statusCodeIsSuccessful = false
        if let statusCode = statusCode, Self.successfulStatusCodes.contains(statusCode) {
            statusCodeIsSuccessful = true
        }
        
        if statusCodeIsSuccessful, let decodedResponse = decodedResponse {
            completion(.success(decodedResponse))
        } else if statusCodeIsSuccessful, decodedResponse == nil {
            completion(.failure(.parsingResponse))
        } else if let statusCodeError = statusCodeError {
            completion(.failure(statusCodeError))
        } else if let decodedError = decodedError {
            completion(.failure(.apiError(message: decodedError.error)))
        } else if let afError = response.error {
            completion(.failure(.afError(error: afError)))
        } else {
            completion(.failure(.unknown))
        }
    }
}
