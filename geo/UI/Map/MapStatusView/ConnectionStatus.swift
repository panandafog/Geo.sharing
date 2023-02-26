//
//  ConnectionStatus.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

enum ConnectionStatus: Int {
    case ok = 0
    case notStarted = 1
    case establishing = 2
    case failed = 3
    
    static let initial = ConnectionStatus.notStarted
}
