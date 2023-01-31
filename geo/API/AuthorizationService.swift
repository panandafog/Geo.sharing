//
//  AuthorizationService.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Alamofire

class AuthorizationService: ApiService {
    
    var uid: String?
    var token: String?
    
    var authorized: Bool {
        token != nil && uid != nil
    }
    
    static let shared = AuthorizationService()
    static let minUsernameLength = 6
    static let minPasswordLength = 6
    
    private init() {}
    
    func login(username: String, password: String, completion: @escaping (Result<Void, ApiError>) -> Void) {
        let parameters = [
            "username": username,
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
    
    func signup(username: String, password: String, completion: @escaping (Result<Void, ApiError>) -> Void) {
        let parameters = [
            "username": username,
            "password": password
        ]
        _ = AF.request(
            Endpopints.signupComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseDecodable(of: SignupResponse.self) { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
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
}
