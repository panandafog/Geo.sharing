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
    @Published var invalidInput: InvalidInputType?
    
    var email: String? {
        didSet {
            verifyCreds()
        }
    }
    
    init(delegate: RequestPasswordResetViewModelDelegate) {
        self.delegate = delegate
    }
    
    func setInitialInput() {
        self.email = authorizationService.email
    }
    
    private func verifyCreds() {
        let emailIsValid = email?.isValidEmailAddress ?? false
        confirmationAllowed = emailIsValid
        
        if !emailIsValid {
            invalidInput = .invalidEmail
        } else {
            invalidInput = nil
        }
    }
    
    func confirmResetPassword() {
        guard let email = email else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.requestPasswordChange(email: email) { [weak self] result in
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

extension RequestPasswordResetViewModel {
    
    enum InvalidInputType {
        case invalidEmail
    }
}
