//
//  ResetPasswordViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Foundation

protocol ResetPasswordViewModelDelegate: AnyObject {
    func handlePasswordResetCompletion()
    func handleError(error: RequestError)
}

class ResetPasswordViewModel: ObservableObject {
    
    private let authorizationService = AuthorizationService.shared
    
    private weak var delegate: ResetPasswordViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    
    var newPassword: String? {
        didSet {
            verifyCreds()
        }
    }
    var passwordConfirmation: String? {
        didSet {
            verifyCreds()
        }
    }
    var code: Int? {
        didSet {
            verifyCreds()
        }
    }
    
    init(delegate: ResetPasswordViewModelDelegate) {
        self.delegate = delegate
    }
    
    private func verifyCreds() {
        confirmationAllowed = (newPassword ?? "").count >= AuthorizationService.minPasswordLength
        && newPassword == passwordConfirmation
        && code != nil
        && String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
    
    
    func confirmChangingPassword() {
        guard let code = code, let newPassword = newPassword else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.confirmPasswordChange(
            code: code,
            newPassword: newPassword
        ) { [weak self] result in
            self?.changesAllowed = true
            self?.confirmationAllowed = true
            self?.activityInProgress = false
            
            switch result {
            case .success(()):
                self?.authorizationService.signOut()
                self?.delegate?.handlePasswordResetCompletion()
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
