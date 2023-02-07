//
//  MKAnnotation+Extensions.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import MapKit

extension MKAnnotation where Self: Equatable {
    
    func isVisible(on map: MKMapView) -> Bool {
        map.visibleAnnotations.contains {
            ($0 as? Self) == self
        }
    }
}
