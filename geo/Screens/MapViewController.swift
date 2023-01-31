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
    @IBOutlet var usersButton: UIButton!
    @IBOutlet var myLocationButton: UIButton!
    
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    
    private let mapZoomOffset = 200
    private let friendsBarHeight = 20
    
    private var cancellableBag = Set<AnyCancellable>()
    
    private lazy var friendsViewController: UsersViewController = {
        let viewController = UIViewController.instantiate(name: "UsersViewController") as! UsersViewController
        return viewController
    }()
    
    private lazy var notificationsViewController: NotificationsViewController = {
        let viewController = UIViewController.instantiate(name: "NotificationsViewController") as! NotificationsViewController
        return viewController
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
        
        authorizeAndStart()
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
        
        testAnnotation()
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
    
    private func showUsers() {
//        self.friendsViewController.view.snp.remakeConstraints { make in
//            make.width.equalToSuperview()
//            make.height.equalToSuperview()
//            make.top.equalToSuperview()
//            make.centerX.equalToSuperview()
//        }
//        UIView.animate(withDuration: 0.5) {
//            self.view.layoutIfNeeded()
//        }
        navigationController?.pushViewController(friendsViewController, animated: true)
    }
    
    private func showNotifications() {
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }
    
    func testAnnotation() {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 60, longitude: 30.2)
        annotation1.title = "Example 0" // Optional
        annotation1.subtitle = "Example 0 subtitle" // Optional
        map.addAnnotation(annotation1)
    }
    
    @IBAction func notificationsButtonTouched(_ sender: UIButton) {
        showNotifications()
    }
    
    @IBAction func usersButtonTouched(_ sender: UIButton) {
        showUsers()
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

