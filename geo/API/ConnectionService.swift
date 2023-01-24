//
//  ConnectionService.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Alamofire
import CoreLocation

enum ConnectionService {
    
    typealias SendingLocationCompletion = (Result<Void, LocationError>) -> Void
    
    private static var authorizationHeader: HTTPHeader? {
        guard let token = AuthorizationService.shared.token else {
            return nil
        }
        return .authorization(bearerToken: token)
    }
    
    static func sendLocation(_ location: CLLocation, completion: @escaping SendingLocationCompletion) {
        sendLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            completion: completion
        )
    }
    
    static func sendLocation(latitude: Double, longitude: Double, completion: @escaping SendingLocationCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "latitude": latitude,
            "longitude": longitude
        ]
        
        _ = AF.request(
            Endpopints.saveLocationComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
}

extension ConnectionService {
    
    enum LocationError: Error {
        case wrongCreds
        case parsingResponse
        case unknown
    }
}
