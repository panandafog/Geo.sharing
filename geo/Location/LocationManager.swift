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
    
    var premissionStatus: PermissionStatus {
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
            return .ok
        @unknown default:
            return .needToRequest
        }
    }
    
    @Published var location: CLLocation?
    
    @Published var connectionStatus: ConnectionStatus = .initial
    @Published var locationStatus: LocationStatus = .initial
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startUpdatingLocation(delegate: LocationManagerDelegate) {
        switch premissionStatus {
        case .needToRequest:
            locationManager.requestAlwaysAuthorization()
        case .denied:
            delegate.openLocationSettings()
        default:
            break
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationStatus = .initial
        connectionStatus = .initial
    }
    
    private func updateLocationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationStatus = .noPermission
        case .restricted:
            locationStatus = .noPermission
        case .denied:
            locationStatus = .noPermission
        case .authorizedAlways:
            locationStatus = .notStarted
        case .authorizedWhenInUse:
            locationStatus = .notStarted
        @unknown default:
            locationStatus = .noPermission
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if connectionStatus != .ok {
            connectionStatus = .establishing
        }
        self.location = locations.first
        self.locationStatus = .ok
        
        if let location = self.location {
            LocationService.sendLocation(location) { result in
                switch result {
                case .success:
                    self.connectionStatus = .ok
                case .failure:
                    self.connectionStatus = .failed
                }
            }
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
        updateLocationStatus()
    }
}

extension LocationManager {
    
    enum PermissionStatus {
        case ok
        case needToRequest
        case denied
    }
}
