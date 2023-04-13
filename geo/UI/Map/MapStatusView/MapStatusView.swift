//
//  MapStatusView.swift
//  geo
//
//  Created by Andrey on 24.02.2023.
//

import Combine
import UIKit

class MapStatusView: UIButton {
    
    private let hidingAnimationDuration = 0.3
    private let apperingAnimationDuration = 0.3
    
    var viewModel: MapStatusViewModel?
    
    private var cancellables: Set<AnyCancellable> = []
    
    func setup(viewModel: MapStatusViewModel) {
        self.viewModel = viewModel
        bindViewModel()
        setStatus(viewModel.mapStatus)
        isUserInteractionEnabled = false
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.statusPublisher.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.setStatus(output)
            }
        }
        .store(in: &cancellables)
    }
    
    private func setStatus(_ status: MapStatus) {
        configuration = status.configuration
        isUserInteractionEnabled = status.action != nil
        if status.shouldBeHidden != isHidden {
            if status.shouldBeHidden {
                UIView.animate(
                    withDuration: hidingAnimationDuration,
                    animations: { self.alpha = 0 },
                    completion: { self.isHidden = $0 }
                )
            } else {
                alpha = 0
                isHidden = false
                UIView.animate(withDuration: apperingAnimationDuration) {
                    self.alpha = 1
                }
            }
        }
    }
}

extension MapStatus {
    var shouldBeHidden: Bool {
        locationStatus == .ok && connectionStatus == .ok
    }
    var configuration: UIButton.Configuration {
        if locationStatus == .noPermission {
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .systemRed
            configuration.baseForegroundColor = .white
            configuration.title = "No location permission"
            return configuration
        } else {
            return connectionStatus.configuration
        }
    }
}

extension ConnectionStatus {
    var configuration: UIButton.Configuration {
        switch self {
        case .ok:
            var configuration = UIButton.Configuration.tinted()
            configuration.baseBackgroundColor = .systemGreen
            configuration.baseForegroundColor = .systemGreen
            configuration.title = "Connected"
            return configuration
        case .establishing:
            var configuration = UIButton.Configuration.tinted()
            configuration.baseBackgroundColor = .systemOrange
            configuration.baseForegroundColor = .systemOrange
            configuration.title = "Connecting"
            
            configuration.showsActivityIndicator = true
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 8.0
            
            return configuration
        case .failed:
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .systemRed
            configuration.baseForegroundColor = .white
            configuration.title = "Connection failed"
            return configuration
        case .notStarted:
            var configuration = UIButton.Configuration.tinted()
            configuration.baseBackgroundColor = .systemGray
            configuration.baseForegroundColor = .label
            configuration.title = "Not connected"
            return configuration
        }
    }
}
