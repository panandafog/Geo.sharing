//
//  AuthorizationService.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Alamofire

class AuthorizationService: ApiService {
    
    let defaults = UserDefaults.standard
    
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
    
    static let shared = AuthorizationService()
    static let minUsernameLength = 6
    static let minPasswordLength = 6
    static let confirmationCodeLength = 6
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping EmptyCompletion) {
        let parameters = [
            "email": email,
            "password": password
        ]
        _ = AF.request(
            Endpopints.loginComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseDecodable(of: LoginResponse.self) { (response) in
            guard let value = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            self.token = value.token
            self.uid = value.id
            self.email = value.email
            self.username = value.username
            completion(.success(()))
        }
    }
    
    func signup(username: String, email: String, password: String, completion: @escaping (Result<SignupResponse, ApiError>) -> Void) {
        let parameters = [
            "username": username,
            "email": email,
            "password": password
        ]
        _ = AF.request(
            Endpopints.signupComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseDecodable(of: SignupResponse.self) { (response) in
            guard let response = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(response))
        }
    }
    
    func verifyEmail(code: Int, signupResponse: SignupResponse, completion: @escaping EmptyCompletion) {
        let parameters = [
            "user_id": signupResponse.id,
            "code": String(code)
        ]
        _ = AF.request(
            Endpopints.confirmEmailComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseDecodable(of: EmailConfirmationResponse.self) { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    func requestPasswordChange(completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        
        _ = AF.request(
            Endpopints.requestPasswordChangeComponents.url!,
            method: .get,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    func confirmPasswordChange(code: Int, newPassword: String, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "code": String(code),
            "new_password": newPassword
        ]
        
        _ = AF.request(
            Endpopints.confirmPasswordChangeComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            self.signOut()
            completion(.success(()))
        }
    }
    
    func signOut() {
        uid = nil
        token = nil
        email = nil
        username = nil
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
