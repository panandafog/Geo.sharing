//
//  AuthorizationService.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Alamofire

class AuthorizationService: ApiService {
    
    let defaults = UserDefaults.standard
    
    var uid: String? {
        get {
            defaults.string(forKey: "uid")
        }
        set {
            defaults.set(newValue, forKey: "uid")
        }
    }
    
    var token: String? {
        get {
            defaults.string(forKey: "token")
        }
        set {
            defaults.set(newValue, forKey: "token")
        }
    }
    
    var authorized: Bool {
        token != nil && uid != nil
    }
    
    static let shared = AuthorizationService()
    static let minUsernameLength = 6
    static let minPasswordLength = 6
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Result<Void, ApiError>) -> Void) {
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
    
    func verifyEmail(code: Int, signupResponse: SignupResponse, completion: @escaping (Result<Void, ApiError>) -> Void) {
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
    
    func signOut() {
        uid = nil
        token = nil
    }
}

extension AuthorizationService {
    
    struct LoginResponse: Decodable {
        let token: String
        let id: String
    }
    
    struct SignupResponse: Decodable {
        let id: String
    }
    
    struct EmailConfirmationResponse: Decodable {
        let id: String
    }
}
