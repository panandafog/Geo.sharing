//
//  AuthorizationService.swift
//  geo
//
//  Created by Andrey on 19.01.2023.
//

import Alamofire

class AuthorizationService {
    
    var token: String?
    
    var authorized: Bool {
        token != nil
    }
    
    static let shared = AuthorizationService()
    static let minUsernameLength = 6
    static let minPasswordLength = 6
    
    private init() {}
    
    func login(username: String, password: String, completion: @escaping (Result<Void, LoginError>) -> Void) {
        let parameters = [
            "username": username,
            "password": password
        ]
        print(Endpopints.loginComponents.url!)
        _ = AF.request(
            Endpopints.loginComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseDecodable(of: LoginResponse.self) { (response) in
            guard let token = response.value?.token else {
                completion(.failure(.parsingResponse))
                return
            }
            self.token = token
            completion(.success(()))
        }
    }
}

extension AuthorizationService {
    
    struct LoginResponse: Decodable {
        let token: String
    }
    
    enum LoginError: Error {
        case wrongCreds
        case parsingResponse
        case unknown
    }
}
