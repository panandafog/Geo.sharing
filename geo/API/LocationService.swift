//
//  LocationService.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Alamofire
import CoreLocation

enum LocationService: ApiService {
    
    typealias SendingLocationCompletion = (Result<Void, ApiError>) -> Void
    
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
