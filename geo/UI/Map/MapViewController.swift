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

protocol MapViewControllerDelegate: AnyObject {
    func showNotifications()
    func showSettings()
    func showFriends()
    func showAuthorization()
}

class MapViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    private lazy var viewModel = MapViewModel(delegate: self)
    weak var coordinator: MapViewControllerDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let mapZoomOffset = 200
    private let friendsBarHeight = 20
    
    private var zoomMapToUserEnabled: Bool {
        get {
            map.userTrackingMode != .none
        }
        set {
            map.setUserTrackingMode(
                newValue ? .follow : .none,
                animated: true
            )
        }
    }
    
    private let enabledLocationButtonConfiguration: UIButton.Configuration = {
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "location.fill")
        return configuration
    }()
    private let disabledLocationButtonConfiguration: UIButton.Configuration = {
        var configuration = UIButton.Configuration.tinted()
        configuration.image = UIImage(systemName: "location.fill")
        return configuration
    }()
    private var locationButtonConfiguration: UIButton.Configuration {
        if zoomMapToUserEnabled {
            return enabledLocationButtonConfiguration
        } else {
            return disabledLocationButtonConfiguration
        }
    }
    
    @IBOutlet private var map: MKMapView!
    @IBOutlet private var notificationsButton: UIButton!
    @IBOutlet private var settingsButton: UIButton!
    @IBOutlet private var usersButton: UIButton!
    @IBOutlet private var myLocationButton: UIButton!
    @IBOutlet private var mapStatusView: MapStatusView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        setupMap()
        setupMapStatusView()
        setLocationButtonConfiguration()
        
        viewModel.authorizeAndStart()
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
        zoomMapToUserEnabled.toggle()
        setLocationButtonConfiguration()
    }
    
    @IBAction private func connectionStatusViewTouched(_ sender: MapStatusView) {
        viewModel.mapStatus.action?()
    }
    
    private func bindViewModel() {
        viewModel.$notificationsCount.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateNotificationsButton()
            }
        }
        .store(in: &cancellables)
        
        viewModel.$friendships.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateAnnotations()
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Event handlers
    
    func handleLoginCompletion() {
        viewModel.handleLoggigIn()
    }
    
    func handleSignoutCompletion() {
        viewModel.signOut()
    }
    
    func show(user: User) {
        guard let latitude = user.latitude,
              let longitude = user.longitude else {
            return
        }
        
        zoomMapTo(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - UI
    
    private func setLocationButtonConfiguration() {
        self.myLocationButton.configuration = locationButtonConfiguration
    }
    
    private func setupMapStatusView() {
        mapStatusView.setup(viewModel: viewModel)
    }
    
    // MARK: - Map
    
    private func setupMap() {
        map.register(FriendAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FriendAnnotationView")
        map.delegate = self
        zoomMapToUserEnabled = true
    }
    
    private func zoomMapTo(latitude: Double, longitude: Double) {
        zoomMapTo(coordinate: .init(
            latitude: latitude,
            longitude: longitude
        ))
    }
    
    private func zoomMapToUserLocation(animated: Bool = true) {
        guard let userLocation = viewModel.userLocation else {
            return
        }
        zoomMapTo(coordinate: userLocation, animated: animated)
    }
    
    private func zoomMapTo(coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let viewRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: CLLocationDistance(mapZoomOffset),
            longitudinalMeters: CLLocationDistance(mapZoomOffset)
        )
        map.setRegion(viewRegion, animated: animated)
    }
    
    // MARK: - Annotations
    
    private func updateAnnotations() {
        let existingAnnotations = map.annotations.compactMap {
            $0 as? FriendMKPointAnnotation
        }
        // remove unneeded annotations
        for annotation in existingAnnotations where !viewModel.friends.contains(annotation.user) {
            map.removeAnnotation(annotation)
        }
        
        for user in viewModel.friends {
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
    
    private func updateNotificationsButton() {
        if viewModel.notificationsCount > 0 {
            notificationsButton.tintColor = .systemOrange
        } else {
            notificationsButton.tintColor = .systemGray
        }
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
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setLocationButtonConfiguration()
    }
}

extension MapViewController: MapViewModelDelegate {
    
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
    
    func showAuthorization() {
        coordinator?.showAuthorization()
    }
}

extension MapViewController: LocationManagerDelegate { }
