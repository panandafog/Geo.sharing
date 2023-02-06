//
//  FriendMKPointAnnotation.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import MapKit

class FriendMKPointAnnotation: MKPointAnnotation {
    
    var user: User
    
    init?(user: User) {
        guard let latitude = user.latitude, let longitude = user.longitude else {
            return nil
        }
        self.user = user
        super.init()
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
