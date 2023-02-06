//
//  FriendMKPointAnnotation.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import MapKit
import UIKit

class FriendMKPointAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var user: User
    
    init?(user: User) {
        guard let latitude = user.latitude, let longitude = user.longitude else {
            return nil
        }
        self.user = user
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        super.init()
    }
}
