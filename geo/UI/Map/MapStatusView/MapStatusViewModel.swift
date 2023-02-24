//
//  MapStatusViewModel.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

import Combine

protocol MapStatusViewModel {
    
    var statusPublisher: Published<MapStatus>.Publisher { get }
    var mapStatus: MapStatus { get }
}
