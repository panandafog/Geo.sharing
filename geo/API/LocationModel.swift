//
//  LocationModel.swift
//  geo
//
//  Created by Andrey on 18.12.2022.
//

import Foundation
import CoreLocation

struct LocationModel: Codable {
    let latitude: Double
    let longitude: Double
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}
