//
//  MKMapView+Extensions.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import MapKit

extension MKMapView {
    
    var visibleAnnotations: [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect)
            .map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
    
    
}
