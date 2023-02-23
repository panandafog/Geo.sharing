//
//  MapViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import MapKit

protocol MapViewModelDelegate: AnyObject {
    func handleError(error: RequestError)
    func showAuthorization()
}

class MapViewModel: ObservableObject {
    
    private static let notificationsUpdateInterval = 2.0
    private static let friendshipsUpdateInterval = 2.0
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private weak var delegate: MapViewModelDelegate?
    
    private var friendshipsTimer: Timer?
    private var notificationsTimer: Timer?
    
    @Published var notificationsCount = 0
    @Published var friendships: [Friendship] = []
    
    var friends: [User] {
        friendships.compactMap { $0.user }
    }
    
    var userLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    init(delegate: MapViewModelDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Location
    
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
        usersService.getFriendships { [weak self] result in
            switch result {
            case .success(let friendships):
                self?.friendships = friendships
            case .failure(let error):
                self?.delegate?.handleError(error: error)
                self?.stopUpdatingFriendships()
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
