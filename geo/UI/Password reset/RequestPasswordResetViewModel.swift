//
//  RequestPasswordResetViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Foundation

protocol RequestPasswordResetViewModelDelegate: AnyObject {
    func handlePasswordResetConfirmation()
    func handleError(error: RequestError)
}

class RequestPasswordResetViewModel: ObservableObject {
    
    private let authorizationService = AuthorizationService.shared
    
    private weak var delegate: RequestPasswordResetViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    
    var email: String? {
        didSet {
            verifyCreds()
        }
    }
    
    init(delegate: RequestPasswordResetViewModelDelegate) {
        self.delegate = delegate
    }
    
    private func verifyCreds() {
        confirmationAllowed = email?.isValidEmailAddress ?? false
    }
    
    func confirmResetPassword() {
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.requestPasswordChange { [weak self] result in
            self?.changesAllowed = true
            self?.confirmationAllowed = true
            self?.activityInProgress = false
            
            switch result {
            case .success(()):
                self?.delegate?.handlePasswordResetConfirmation()
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
