//
//  MapViewController.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Combine
import MapKit
import SnapKit
import UIKit

class MapViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: MainCoordinator?
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    private let usersService = UsersService.self
    private let friendsService = FriendsService.self
    
    private let mapZoomOffset = 200
    private let friendsBarHeight = 20
    
    private var cancellableBag = Set<AnyCancellable>()
    private var annotationsTimer: Timer?
    private var notificationsTimer: Timer?
    
//    private lazy var settingsViewController: SettingsViewController = {
//        let viewController = UIViewController.instantiate(name: "SettingsViewController") as! SettingsViewController
        
        // TODO: handle signout
//        viewController.signOutHandler = { [weak self] in
//            if let vc = self {
//                self?.navigationController?.popToViewController(
//                    vc,
//                    animated: true
//                )
//            }
//
//            self?.stopUpdatingLocation()
//            self?.stopUpdatingUsersAnnotations()
//            self?.stopUpdatingNotifications()
//
//            self?.removeAllUsersAnnotations()
//            self?.authorizationService.signOut()
//            self?.authorizeAndStart()
//        }
//        return viewController
//    }()
    
    @IBOutlet private var map: MKMapView!
    @IBOutlet private var notificationsButton: UIButton!
    @IBOutlet private var settingsButton: UIButton!
    @IBOutlet private var usersButton: UIButton!
    @IBOutlet private var myLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        authorizeAndStart()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction private func notificationsButtonTouched(_ sender: UIButton) {
        coordinator?.showNotifications()
    }
    
    @IBAction private func settingsButtonTouched(_ sender: UIButton) {
        coordinator?.showSettings()
    }
    
    @IBAction private func usersButtonTouched(_ sender: UIButton) {
        coordinator?.showFriends()
    }
    
    @IBAction private func mylocationButtonTouched(_ sender: UIButton) {
        zoomMapToUserLocation()
    }
    
    // MARK: - Map
    
    private func setupMap() {
        map.register(FriendAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FriendAnnotationView")
        map.delegate = self
    }
    
    private func zoomMapToUserLocation(animated: Bool = true) {
        guard let userLocation = locationManager.location?.coordinate else {
            return
        }
        let userViewRegion = MKCoordinateRegion(
            center: userLocation,
            latitudinalMeters: CLLocationDistance(mapZoomOffset),
            longitudinalMeters: CLLocationDistance(mapZoomOffset)
        )
        map.setRegion(userViewRegion, animated: animated)
    }
    
    // MARK: - Location
    
    private func authorizeAndStart() {
        guard !authorizationService.authorized else {
            startUpdatingLocation()
            startUpdatingUsersAnnotations()
            startUpdatingNotifications()
            return
        }
        
        coordinator?.showAuthorization()
        
//        let navigationViewController = UINavigationController()
//        let loginViewController = UIViewController.instantiate(name: "LoginViewController") as! LoginViewController
//        loginViewController.parentNavigationController = navigationController
//        loginViewController.isModalInPresentation = true
        // TODO: handle success
//        loginViewController.successCompletion = { [weak self] in
//            loginViewController.dismiss(animated: true)
//            self?.startUpdatingLocation()
//            self?.startUpdatingUsersAnnotations()
//            self?.startUpdatingNotifications()
//        }
//        navigationViewController.viewControllers = [loginViewController]
//        present(navigationViewController, animated: true)
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        var zoomed = false
        locationManager.$location.sink { newLocation in
            DispatchQueue.main.async { [weak self] in
                guard newLocation != nil else {
                    return
                }
                
                if !zoomed {
                    self?.zoomMapToUserLocation()
                    zoomed = true
                }
            }
        }
        .store(in: &cancellableBag)
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Annotations
    
    private func startUpdatingUsersAnnotations() {
        annotationsTimer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { [weak self] _ in
            self?.updateUsersForAnnotations()
        }
    }
    
    private func stopUpdatingUsersAnnotations() {
        annotationsTimer?.invalidate()
    }
    
    private func removeAllUsersAnnotations() {
        updateAnnotations(users: [])
    }
    
    private func updateUsersForAnnotations() {
        usersService.getFriendships { [weak self] result in
            switch result {
            case .success(let friendships):
                self?.updateAnnotations(users: friendships.compactMap { $0.user })
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func updateAnnotations(users: [User]) {
        let existingAnnotations = map.annotations.compactMap {
            $0 as? FriendMKPointAnnotation
        }
        // remove unneeded annotations
        for annotation in existingAnnotations where !users.contains(annotation.user) {
            map.removeAnnotation(annotation)
        }
        
        for user in users {
            if let existingAnnotation = existingAnnotations.first(where: { $0.user == user }) {
                // move existing annotation
                UIView.animate(withDuration: 1) {
                    existingAnnotation.user = user
                }
            } else {
                // add new annotation
                guard let annotation = FriendMKPointAnnotation(user: user) else {
                    continue
                }
                map.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: - Notifications
    
    private func startUpdatingNotifications() {
        notificationsTimer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { [weak self] _ in
            self?.updateNotifications()
        }
    }
    
    private func stopUpdatingNotifications() {
        notificationsTimer?.invalidate()
    }
    
    private func updateNotifications() {
        friendsService.getFriendshipRequests(type: .incoming) { [weak self] result in
            switch result {
            case .success(let friendshipRequests):
                self?.handleNotifications(exist: !friendshipRequests.isEmpty)
                
            case .failure:
                break
            }
        }
    }
    
    private func handleNotifications(exist: Bool) {
        notificationsButton.tintColor = exist ? .systemOrange : .systemGray
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is FriendMKPointAnnotation else {
            return nil
        }

        let identifier = "FriendAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? FriendAnnotationView

        if annotationView == nil {
            annotationView = FriendAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView!.annotation = annotation
        }

        annotationView?.setupUI()
        return annotationView
    }
}
