//
//  FriendsService.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import Alamofire

enum FriendsService: ApiService {
    
    typealias FriendshipRequestsCompletion = (Result<[FriendshipRequest], ApiError>) -> Void
    
    static func getFriendshipRequests(type: FriendshipRequestType, completion: @escaping FriendshipRequestsCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        
        let urlComponents: URLComponents
        switch type {
        case .incoming:
            urlComponents = Endpopints.getIncomingFriendshipRequestsComponents
        case .outgoing:
            urlComponents = Endpopints.getOutgoingFriendshipRequestsComponents
        }
        
        _ = AF.request(
            urlComponents.url!,
            method: .get,
            headers: headers
        ).responseDecodable(of: [FriendshipRequest].self) { (response) in
            guard let response = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(response))
        }
    }
  
    static func answerOnFriendshipRequest(senderID: String, accept: Bool, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "sender_id": senderID
        ]
        
        let urlComponents: URLComponents
        if accept {
            urlComponents = Endpopints.acceptFriendshipRequestComponents
        } else {
            urlComponents = Endpopints.rejectFriendshipRequestComponents
        }
        
        _ = AF.request(
            urlComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    static func sendFriendshipRequest(recipientID: String, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "recipient_id": recipientID
        ]
        
        _ = AF.request(
            Endpopints.createFriendshipRequestComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    static func deleteFriendshipRequest(recipientID: String, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "recipient_id": recipientID
        ]
        
        _ = AF.request(
            Endpopints.deleteFriendshipRequestComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    static func deleteFriend(userID: String, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "user_id": userID
        ]
        
        _ = AF.request(
            Endpopints.deleteFriendComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).response { (response) in
            guard let _ = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
}
