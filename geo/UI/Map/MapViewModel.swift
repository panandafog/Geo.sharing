//
//  MapViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import MapKit

protocol MapViewModelDelegate: LocationManagerDelegate, AnyObject {
    func handleError(error: RequestError)
    func showAuthorization()
}

class MapViewModel: ObservableObject, MapStatusViewModel {
    
    private static let notificationsUpdateInterval = 2.0
    private static let friendshipsUpdateInterval = 2.0
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private weak var delegate: MapViewModelDelegate?
    
    private var friendshipsTimer: Timer?
    private var notificationsTimer: Timer?
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var notificationsCount = 0
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
    
    var friends: [User] {
        friendships.compactMap { $0.user }
    }
    
    var userLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    init(delegate: MapViewModelDelegate) {
        self.delegate = delegate
        bindLocationManager()
    }
    
    // MARK: - Location
    
    func bindLocationManager() {
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
            startUpdatingNotifications()
            return
        }
        
        delegate?.showAuthorization()
    }
    
    func startUpdatingLocation() {
        guard let delegate = delegate else { return }
        locationManager.startUpdatingLocation(delegate: delegate)
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
            case .failure(let error):
                self?.friendsConnectionStatus = .failed
                self?.delegate?.handleError(error: error)
            }
        }
    }
    
    // MARK: - Notifications
    
    func startUpdatingNotifications() {
        notificationsTimer = Timer.scheduledTimer(
            withTimeInterval: Self.notificationsUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateNotifications()
        }
    }
    
    func stopUpdatingNotifications() {
        notificationsTimer?.invalidate()
    }
    
    private func updateNotifications() {
        friendsService.getFriendshipRequests(type: .incoming) { [weak self] result in
            switch result {
            case .success(let friendshipRequests):
                self?.notificationsCount = friendshipRequests.count
                
            case .failure:
                break
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
                guard let self = self,
                      let delegate = self.delegate else {
                    return
                }
                self.locationManager.startUpdatingLocation(
                    delegate: delegate
                )
            }
        }
    }
    
    // MARK: - Other
    
    func signOut() {
        stopUpdatingLocation()
        stopUpdatingFriendships()
        stopUpdatingNotifications()
        
        friendships = []
        authorizationService.signOut()
        
        authorizeAndStart()
    }
    
    func handleLoggigIn() {
        startUpdatingLocation()
        startUpdatingFriendships()
        startUpdatingNotifications()
    }
}
