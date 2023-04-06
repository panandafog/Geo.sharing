//
//  LocationService.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Alamofire
import CoreLocation

class LocationService {
    typealias SendingLocationCompletion = (Result<Void, RequestError>) -> Void
    
    private let authorizationService: AuthorizationService
    
    init(authorizationService: AuthorizationService) {
        self.authorizationService = authorizationService
    }
    
    func sendLocation(_ location: CLLocation, completion: @escaping SendingLocationCompletion) {
        sendLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            completion: completion
        )
    }
    
    func sendLocation(latitude: Double, longitude: Double, completion: @escaping SendingLocationCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.saveLocationComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: [
                    "latitude": latitude,
                    "longitude": longitude
                ],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
}

extension LocationService: SendingRequestsService {
    var authorizationDelegate: AuthorizationDelegate? {
        authorizationService
    }
}
