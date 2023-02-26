//
//  ResetPasswordViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Swinject

protocol ResetPasswordViewModelDelegate: AnyObject {
    func handlePasswordResetCompletion()
    func handleError(error: RequestError)
}

class ResetPasswordViewModel: ObservableObject {
    
    private let authorizationService: AuthorizationService
    
    private weak var delegate: ResetPasswordViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    @Published var invalidInput: InvalidInputType?
    
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
    var email: String?
    
    init(delegate: ResetPasswordViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        self.authorizationService = container.resolve(AuthorizationService.self)!
    }
    
    private func verifyCreds() {
        let passwordIsValid = (newPassword?.count ?? 0) >= AuthorizationService.minPasswordLength
        let passwordConfirmationIsValid = passwordConfirmation == newPassword
        let codeIsValid = String(code ?? 0).count == AuthorizationService.confirmationCodeLength
        
        confirmationAllowed = passwordIsValid && passwordConfirmationIsValid && codeIsValid
        
        if !passwordIsValid && (newPassword?.count ?? 0) > 0 {
            invalidInput = .tooShortPassword
        } else if !passwordConfirmationIsValid && (passwordConfirmation?.count ?? 0) > 0 {
            invalidInput = .unmatchingPasswordConfirmation
        } else if !codeIsValid && code != nil {
            invalidInput = .invalidCode
        } else {
            invalidInput = nil
        }
    }
    
    func confirmChangingPassword() {
        guard
            let code = code,
            let newPassword = newPassword,
            let email = email
        else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.confirmPasswordChange(
            email: email,
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

extension ResetPasswordViewModel {
    
    enum InvalidInputType {
        case tooShortPassword
        case unmatchingPasswordConfirmation
        case invalidCode
    }
}
