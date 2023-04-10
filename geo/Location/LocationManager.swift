//
//  LocationManager.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Combine
import CoreLocation
import Swinject

class LocationManager: NSObject, ObservableObject {
    
    let clLocationManager = CLLocationManager()
    let locationService: LocationService
    let settingsService: SettingsService
    
    var premissionStatus: PermissionStatus {
        switch clLocationManager.authorizationStatus {
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
    
    var delegate: LocationManagerDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(locationService: LocationService, settingsService: SettingsService) {
        self.locationService = locationService
        self.settingsService = settingsService
        super.init()
        
        clLocationManager.delegate = self
        clLocationManager.allowsBackgroundLocationUpdates = true
        clLocationManager.pausesLocationUpdatesAutomatically = false
        
        bindSettingsService()
    }
    
    func startUpdatingLocation(mode: LocationMode? = nil) {
        let mode = mode ?? settingsService.currentLocationMode
        
        switch premissionStatus {
        case .needToRequest:
            clLocationManager.requestAlwaysAuthorization()
        case .denied:
            delegate?.openLocationSettings()
        default:
            break
        }
        
        switch mode {
        case .precise:
            clLocationManager.startUpdatingLocation()
        case .economical:
            clLocationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
        locationStatus = .notStarted
        connectionStatus = .notStarted
    }
    
    private func bindSettingsService() {
        settingsService.$currentLocationMode.sink { [weak self] mode in
            self?.stopUpdatingLocation()
            self?.startUpdatingLocation(mode: mode)
        }
        .store(in: &cancellables)
    }
    
    private func updateLocationStatus() {
        switch clLocationManager.authorizationStatus {
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
