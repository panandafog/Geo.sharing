//
//  FriendMKPointAnnotation.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import MapKit
import UIKit

class FriendMKPointAnnotation: MKPointAnnotation {
//    var coordinate: CLLocationCoordinate2D
    var user: User {
        didSet {
            guard let latitude = user.latitude, let longitude = user.longitude else {
                return
            }
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    init?(user: User) {
        self.user = user
        super.init()
    }
}
