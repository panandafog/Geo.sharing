//
//  EmailConfirmationViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine

protocol EmailConfirmationViewModelDelegate: AnyObject {
    func handleEmailConfirmation(email: String)
    func handleError(error: RequestError)
}

class EmailConfirmationViewModel {
    
    private let authorizationService = AuthorizationService.shared
    
    private weak var delegate: EmailConfirmationViewModelDelegate?
    
    @Published var changesAllowed = true
    @Published var confirmationAllowed = false
    @Published var activityInProgress = false
    
    var signupData: SignupData?
    var code: Int? {
        didSet {
            verifyCode()
        }
    }
    
    init(delegate: EmailConfirmationViewModelDelegate) {
        self.delegate = delegate
    }
    
    private func verifyCode() {
        confirmationAllowed = String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
    
    func verifyEmail() {
        guard let code = code,
              let signupResponse = signupData?.signupResponse,
              let email = signupData?.email else {
            return
        }
        
        changesAllowed = false
        confirmationAllowed = false
        activityInProgress = true
        
        authorizationService.verifyEmail(
            code: code,
            signupResponse: signupResponse
        ) { [weak self] result in
            self?.changesAllowed = true
            self?.confirmationAllowed = true
            self?.activityInProgress = false
            
            switch result {
            case .success:
                self?.delegate?.handleEmailConfirmation(email: email)
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}

extension EmailConfirmationViewModel {
    
    struct SignupData {
        let email: String
        let signupResponse: AuthorizationService.SignupResponse
    }
}
