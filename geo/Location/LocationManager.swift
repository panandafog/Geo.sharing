//
//  LocationManager.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    var status: Status {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .needToRequest
        case .restricted:
            return .denied
        case .denied:
            return .denied
        case .authorizedAlways:
            return .ok
        case .authorizedWhenInUse:
            return .needToRequest
        @unknown default:
            return .needToRequest
        }
    }
    
    @Published var location: CLLocation?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startUpdatingLocation() {
        if status == .needToRequest {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        self.location = locations.first
        if let location = self.location {
            LocationService.sendLocation(location, completion: { _ in })
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("error \(error.localizedDescription)")
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // Handle changes if location permissions
    }
}

extension LocationManager {
    
    enum Status {
        case ok
        case needToRequest
        case denied
    }
}
