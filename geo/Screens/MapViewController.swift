//
//  MapViewController.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Combine
import MapKit
import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    private let locationManager = LocationManager.shared
    private let authorizationService = AuthorizationService.shared
    
    private var cancellableBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            self?.lat.text = "init"
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
        
        print("-=-=- present")
        present(loginViewController, animated: true)
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.$location.sink { newLocation in
            DispatchQueue.main.async { [weak self] in
                guard let newLocation = newLocation else {
                    return
                }
                self?.lat.text = String(newLocation.coordinate.latitude)
                + "\n"
                + String(newLocation.coordinate.longitude)
            }
        }.store(in: &cancellableBag)
        
        testAnnotation()
    }
    
    func testAnnotation() {
        let annotation1 = MKPointAnnotation()
        annotation1.coordinate = CLLocationCoordinate2D(latitude: 60, longitude: 30.2)
        annotation1.title = "Example 0" // Optional
        annotation1.subtitle = "Example 0 subtitle" // Optional
        map.addAnnotation(annotation1)
    }
}

