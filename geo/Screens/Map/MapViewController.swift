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

class MapViewController: UIViewController {
    
    @IBOutlet var debugLocationLabel: UILabel!
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var notificationsButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var usersButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    
    private let mapZoomOffset = 200
    private let friendsBarHeight = 20
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private var debugUsers: [User] = [
        .init(id: "user1", username: "user1", latitude: 60, longitude: 30.2),
        .init(id: "user2", username: "user2", latitude: 60.1, longitude: 30.2),
        .init(id: "user3", username: "user3", latitude: 60.2, longitude: 30.2),
    ]
    
    private lazy var friendsViewController: UsersViewController = {
        UIViewController.instantiate(name: "UsersViewController") as! UsersViewController
    }()
    
    private lazy var notificationsViewController: NotificationsViewController = {
        UIViewController.instantiate(name: "NotificationsViewController") as! NotificationsViewController
    }()
    
    private lazy var settingsViewController: SettingsViewController = {
        UIViewController.instantiate(name: "SettingsViewController") as! SettingsViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            self?.debugLocationLabel.text = "init"
            //            if let friendsViewController = self?.friendsViewController {
            //                self?.addChild(friendsViewController)
            //            }
//            self?.initFriends()
        }
        
        setupMap()
        authorizeAndStart()
    }
    
    private func setupMap() {
        map.register(FriendAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FriendAnnotationView")
        map.delegate = self
    }
    
    private func authorizeAndStart() {
        guard !authorizationService.authorized else {
            startUpdatingLocation()
            return
        }
        
        let loginViewController = UIViewController.instantiate(name: "LoginViewController") as! LoginViewController
        
        loginViewController.isModalInPresentation = true
        loginViewController.successCompletion = { [weak self] in
            loginViewController.dismiss(animated: true)
            self?.startUpdatingLocation()
        }
        
        present(loginViewController, animated: true)
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        var zoomed = false
        locationManager.$location.sink { newLocation in
            DispatchQueue.main.async { [weak self] in
                guard let newLocation = newLocation else {
                    return
                }
                
                if !zoomed {
                    self?.zoomMapToUserLocation()
                    zoomed = true
                }
                
                self?.debugLocationLabel.text = String(newLocation.coordinate.latitude)
                + "\n"
                + String(newLocation.coordinate.longitude)
            }
        }.store(in: &cancellableBag)
        
        addDebugUsersAnnotations()
    }
    
    private func initFriends() {
        addChild(friendsViewController)
        view.addSubview(friendsViewController.view)
        friendsViewController.view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(-friendsBarHeight)
            make.centerX.equalToSuperview()
        }
        friendsViewController.didMove(toParent: self)
    }
    
    private func addDebugUsersAnnotations() {
        for user in debugUsers {
            guard let annotation = FriendMKPointAnnotation(user: user) else {
                continue
            }
            map.addAnnotation(annotation)
        }
    }
    
    @IBAction func notificationsButtonTouched(_ sender: UIButton) {
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }
    
    
    @IBAction func settingsButtonTouched(_ sender: UIButton) {
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    @IBAction func usersButtonTouched(_ sender: UIButton) {
        navigationController?.pushViewController(friendsViewController, animated: true)
    }
    
    @IBAction func mylocationButtonTouched(_ sender: UIButton) {
        zoomMapToUserLocation()
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
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        annotationView?.setupUI()
        return annotationView
    }
}
