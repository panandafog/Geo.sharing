//
//  Coordinator.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] {get set}
    var navigationController: UINavigationController {get set}
    
    func start()
}
