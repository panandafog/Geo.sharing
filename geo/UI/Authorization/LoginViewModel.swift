//
//  LoginViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine

protocol LoginViewModelDelegate: AnyObject {
    func handleLoginCompletion()
    func handleError(error: RequestError)
}

class LoginViewModel {
    
    private let authorizationService = AuthorizationService.shared
    
    private weak var delegate: LoginViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    
    var email: String? {
        didSet {
            verifyCreds()
        }
    }
    var password: String? {
        didSet {
            verifyCreds()
        }
    }
    
    init(delegate: LoginViewModelDelegate) {
        self.delegate = delegate
    }
    
    private func verifyCreds() {
        confirmationAllowed = (email?.count ?? 0) >= AuthorizationService.minUsernameLength
        && (password?.count ?? 0) >= AuthorizationService.minPasswordLength
        && (email?.isValidEmailAddress ?? false)
    }
    
    func login() {
        guard let email = email,
              let password = password
        else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.login(
            email: email,
            password: password
        ) { [weak self] result in
            
            self?.changesAllowed = true
            self?.confirmationAllowed = true
            self?.activityInProgress = false
            
            switch result {
            case .success:
                self?.delegate?.handleLoginCompletion()
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
