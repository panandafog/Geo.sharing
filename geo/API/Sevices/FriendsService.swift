//
//  FriendsService.swift
//  geo
//
//  Created by Andrey on 31.01.2023.
//

import Alamofire

class FriendsService {
    
    typealias FriendshipRequestsCompletion = (Result<[FriendshipRequest], RequestError>) -> Void
    
    private let authorizationService: AuthorizationService
    
    init(authorizationService: AuthorizationService) {
        self.authorizationService = authorizationService
    }
    
    func getFriendshipRequests(type: FriendshipRequestType, completion: @escaping FriendshipRequestsCompletion) {
        let urlComponents: URLComponents
        switch type {
        case .incoming:
            urlComponents = Endpoints.getIncomingFriendshipRequestsComponents
        case .outgoing:
            urlComponents = Endpoints.getOutgoingFriendshipRequestsComponents
        }
        
        sendRequest(
            method: .get,
            url: urlComponents.url!,
            requiresAuthorization: true,
            completion: completion
        )
    }
  
    func answerOnFriendshipRequest(senderID: String, accept: Bool, completion: @escaping EmptyCompletion) {
        let urlComponents: URLComponents
        if accept {
            urlComponents = Endpoints.acceptFriendshipRequestComponents
        } else {
            urlComponents = Endpoints.rejectFriendshipRequestComponents
        }
        
        sendRequest(
            method: .post,
            url: urlComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: ["sender_id": senderID],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func sendFriendshipRequest(recipientID: String, completion: @escaping EmptyCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.createFriendshipRequestComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: ["recipient_id": recipientID],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func deleteFriendshipRequest(recipientID: String, completion: @escaping EmptyCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.deleteFriendshipRequestComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: ["recipient_id": recipientID],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
    
    func deleteFriend(userID: String, completion: @escaping EmptyCompletion) {
        sendRequest(
            method: .post,
            url: Endpoints.deleteFriendComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: ["user_id": userID],
                encoding: .jsonBody
            ),
            completion: completion
        )
    }
}

extension FriendsService: SendingRequestsService {
    var authorizationDelegate: AuthorizationDelegate? {
        authorizationService
    }
}
