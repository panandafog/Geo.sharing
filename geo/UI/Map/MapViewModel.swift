//
//  MapViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import MapKit
import Swinject

protocol MapViewModelDelegate: LocationManagerDelegate, AnyObject {
    func handleError(error: RequestError)
    func showAuthorization()
}

class MapViewModel: ObservableObject, MapStatusViewModel {
    
    private static let friendshipsUpdateInterval = 2.0
    
    private let locationManager: LocationManager
    private let authorizationService: AuthorizationService
    private let usersService: UsersService
    private let friendsService: FriendsService
    
    private weak var delegate: MapViewModelDelegate?
    
    private var friendshipsTimer: Timer?
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var friendships: [Friendship] = []
    
    @Published var mapStatus = MapStatus(
        connectionStatus: .initial,
        locationStatus: .initial,
        action: nil
    )
    var statusPublisher: Published<MapStatus>.Publisher {
        $mapStatus
    }
    
    private var friendsConnectionStatus: ConnectionStatus = .initial {
        didSet {
            updateConnectionStatus()
        }
    }
    private var locationConnectionStatus: ConnectionStatus = .initial {
        didSet {
            updateConnectionStatus()
        }
    }
    
    private var handledConnectionError = false
    
    var friends: [User] {
        friendships.compactMap { $0.user() }
    }
    
    var userLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    init(delegate: MapViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        
        self.locationManager = container.resolve(LocationManager.self)!
        self.authorizationService = container.resolve(AuthorizationService.self)!
        self.usersService = container.resolve(UsersService.self)!
        self.friendsService = container.resolve(FriendsService.self)!
        
        bindLocationManager()
    }
    
    // MARK: - Location
    
    func bindLocationManager() {
        locationManager.delegate = delegate
        
        locationManager.$locationStatus.sink { [weak self] output in
            self?.mapStatus.locationStatus = output
        }
        .store(in: &cancellables)
        
        locationManager.$connectionStatus.sink { [weak self] output in
            self?.locationConnectionStatus = output
        }
        .store(in: &cancellables)
    }
    
    func authorizeAndStart() {
        guard !authorizationService.authorized else {
            startUpdatingLocation()
            startUpdatingFriendships()
            return
        }
        
        delegate?.showAuthorization()
    }
    
    func startUpdatingLocation() {
        guard let delegate = delegate else { return }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Friendships
    
    func startUpdatingFriendships() {
        friendshipsTimer = Timer.scheduledTimer(
            withTimeInterval: Self.friendshipsUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateFriendships()
        }
    }
    
    func stopUpdatingFriendships() {
        friendshipsTimer?.invalidate()
    }
    
    private func updateFriendships() {
        if friendsConnectionStatus != .ok {
            friendsConnectionStatus = .establishing
        }
        
        usersService.getFriendships { [weak self] result in
            switch result {
            case .success(let friendships):
                self?.friendsConnectionStatus = .ok
                self?.friendships = friendships
                self?.handledConnectionError = false
            case .failure(let error):
                self?.friendsConnectionStatus = .failed
                if !(self?.handledConnectionError ?? true) {
                    self?.delegate?.handleError(error: error)
                    self?.handledConnectionError = true
                }
            }
        }
    }
    
    // MARK: - ConnectionStatus
    
    func updateConnectionStatus() {
        mapStatus.connectionStatus = ConnectionStatus(
            rawValue: max(friendsConnectionStatus.rawValue, locationConnectionStatus.rawValue)
        ) ?? .failed
        
        if mapStatus.action == nil {
            mapStatus.action = { [weak self] in
                guard let self = self else {
                    return
                }
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    // MARK: - Other
    
    func signOut() {
        stopUpdatingLocation()
        stopUpdatingFriendships()
        
        friendships = []
        authorizationService.signOut()
        
        authorizeAndStart()
    }
    
    func handleLoggigIn() {
        startUpdatingLocation()
        startUpdatingFriendships()
    }
}
