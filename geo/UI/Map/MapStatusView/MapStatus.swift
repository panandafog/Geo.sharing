//
//  MapStatus.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

struct MapStatus {
    var connectionStatus: ConnectionStatus
    var locationStatus: LocationStatus
    
    var action: (() -> Void)?
}
