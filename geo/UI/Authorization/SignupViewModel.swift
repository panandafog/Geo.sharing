//
//  SignupViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine

protocol SignupViewModelDelegate: AnyObject {
    func showEmailConfirmation(signupData: EmailConfirmationViewModel.SignupData)
    func handleError(error: RequestError)
}

class SignupViewModel {
    
    private let authorizationService = AuthorizationService.shared
    
    private weak var delegate: SignupViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    @Published var invalidInput: InvalidInputType?
    
    var username: String? {
        didSet {
            verifyCreds()
        }
    }
    var password: String? {
        didSet {
            verifyCreds()
        }
    }
    var passwordConfirm: String? {
        didSet {
            verifyCreds()
        }
    }
    var email: String? {
        didSet {
            verifyCreds()
        }
    }
    
    init(delegate: SignupViewModelDelegate) {
        self.delegate = delegate
    }
    
    private func verifyCreds() {
        let usernameIsValid = (username?.count ?? 0) >= AuthorizationService.minUsernameLength
        let emailIsValid = (email?.isValidEmailAddress ?? false)
        let passwordIsValid = (password?.count ?? 0) >= AuthorizationService.minPasswordLength
        let passwordConfirmationIsValid = passwordConfirm == password
        
        confirmationAllowed = usernameIsValid && emailIsValid && passwordIsValid && passwordConfirmationIsValid
        
        if !usernameIsValid && (username?.count ?? 0) > 0 {
            invalidInput = .tooShortUsername
        } else if !emailIsValid && (email?.count ?? 0) > 0 {
            invalidInput = .invalidEmail
        } else if !passwordIsValid && (password?.count ?? 0) > 0 {
            invalidInput = .tooShortPassword
        } else if !passwordConfirmationIsValid && (passwordConfirm?.count ?? 0) > 0 {
            invalidInput = .unmatchingPasswordConfirmation
        } else {
            invalidInput = nil
        }
    }
    
    func signup() {
        guard let username = username,
              let email = email,
              let password = password,
              passwordConfirm == password
        else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.signup(
            username: username,
            email: email,
            password: password
        ) { [weak self] result in
            self?.changesAllowed = true
            self?.confirmationAllowed = true
            self?.activityInProgress = false
            
            switch result {
            case .success(let signupResponse):
                    self?.delegate?.showEmailConfirmation(
                        signupData: .init(
                            email: email,
                            signupResponse: signupResponse
                        )
                    )
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}

extension SignupViewModel {
    
    enum InvalidInputType {
        case tooShortUsername
        case invalidEmail
        case tooShortPassword
        case unmatchingPasswordConfirmation
    }
}
