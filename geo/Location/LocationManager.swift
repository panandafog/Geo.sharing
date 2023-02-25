//
//  LocationManager.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import CoreLocation
import Swinject

class LocationManager: NSObject, ObservableObject {
    
    let locationManager = CLLocationManager()
    let locationService: LocationService
    
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
    
    override convenience init() {
        self.init(container: .defaultContainer)
    }
    
    init(container: Container) {
        locationService = container.resolve(LocationService.self)!
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
            locationService.sendLocation(location) { result in
                switch result {
                case .success:
                    self.connectionStatus = .ok
                case .failure(let error):
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
