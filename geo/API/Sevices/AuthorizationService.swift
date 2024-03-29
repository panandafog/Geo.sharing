//
//  AuthorizationService.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Alamofire
import Combine

class AuthorizationService: ObservableObject {
    
    static let minUsernameLength = 6
    static let minPasswordLength = 6
    static let confirmationCodeLength = 6
    
    private let defaults = UserDefaults.standard
    
    private let uidKey = "uid"
    var uid: String? {
        get {
            defaults.string(forKey: uidKey)
        }
        set {
            defaults.set(newValue, forKey: uidKey)
        }
    }
    
    private let tokenKey = "token"
    var token: String? {
        get {
            defaults.string(forKey: tokenKey)
        }
        set {
            defaults.set(newValue, forKey: tokenKey)
        }
    }
    
    private let emailKey = "email"
    var email: String? {
        get {
            defaults.string(forKey: emailKey)
        }
        set {
            defaults.set(newValue, forKey: emailKey)
        }
    }
    
    private let usernameKey = "username"
    var username: String? {
        get {
            defaults.string(forKey: usernameKey)
        }
        set {
            defaults.set(newValue, forKey: usernameKey)
        }
    }
    
    var authorized: Bool {
        token != nil && uid != nil
    }
    
    func login(email: String, password: String, completion: @escaping EmptyCompletion) {
        let completionHandler: ((Result<LoginResponse, RequestError>) -> Void) = { result in
            switch result {
            case .success(let loginResponse):
                self.token = loginResponse.token
                self.uid = loginResponse.id
                self.email = loginResponse.email
                self.username = loginResponse.username
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        sendRequest(
            method: .post,
            url: Endpoints.loginComponents.url!,
            requiresAuthorization: false,
            parameters: .init(
                parameters: [
                    "email": email,
                    "password": password
                ],
                encoding: .jsonBody
            ),
            completion: completionHandler
        )
    }
    
    func signup(username: String, email: String, password: String, completion: @escaping (Result<SignupResponse, RequestError>) -> Void) {
        sendRequest(
            method: .post,
            url: Endpoints.signupComponents.url!,
            requiresAuthorization: false,
            parameters: .init(
                parameters: [
                    "username": username,
                    "email": email,
                    "password": password
                ],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func verifyEmail(code: Int, signupResponse: SignupResponse, completion: @escaping EmptyCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.confirmEmailComponents.url!,
            requiresAuthorization: false,
            parameters: .init(
                parameters: [
                    "user_id": signupResponse.id,
                    "code": String(code)
                ],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func requestPasswordChange(email: String, completion: @escaping EmptyCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.requestPasswordChangeComponents.url!,
            requiresAuthorization: false,
            parameters: .init(
                parameters: ["email": email],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func confirmPasswordChange(
        email: String,
        code: Int,
        newPassword: String,
        completion: @escaping EmptyCompletion
    ) {
        let completionHandler: EmptyCompletion = { result in
            switch result {
            case .success:
                self.signOut()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        sendRequest(
            method: .post,
            url: Endpoints.confirmPasswordChangeComponents.url!,
            requiresAuthorization: false,
            parameters: .init(
                parameters: [
                    "email": email,
                    "code": String(code),
                    "new_password": newPassword
                ],
                encoding: .jsonBody
            ),
            completion: completionHandler
        )
    }
}

extension AuthorizationService: AuthorizationDelegate {
    
    var authorizationHeader: Alamofire.HTTPHeader? {
        guard let token = token else { return nil }
        return makeAuthorizationHeader(token: token)
    }
    
    func signOut() {
        let wasAuthorized = authorized
        uid = nil
        token = nil
        if wasAuthorized {
            objectWillChange.send()
        }
    }
}

extension AuthorizationService: SendingRequestsService {
    var authorizationDelegate: AuthorizationDelegate? {
        self
    }
}

extension AuthorizationService {
    
    struct LoginResponse: Decodable {
        let token: String
        let id: String
        let username: String
        let email: String
    }
    
    struct SignupResponse: Decodable {
        let id: String
    }
    
    struct EmailConfirmationResponse: Decodable {
        let id: String
    }
}
