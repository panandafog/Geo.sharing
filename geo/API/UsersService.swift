//
//  UsersService.swift
//  geo
//
//  Created by Andrey on 27.01.2023.
//

import Alamofire

enum UsersService: ApiService {
    
    typealias UsersCompletion = (Result<[User], ApiError>) -> Void
    typealias SearchedUsersCompletion = (Result<[SearchedUser], ApiError>) -> Void
    typealias FriendsipsCompletion = (Result<[Friendship], ApiError>) -> Void
    
    private static let friendsService = FriendsService.self
    
    static func getFriendships(completion: @escaping FriendsipsCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        
        _ = AF.request(
            Endpopints.getFriendsComponents.url!,
            method: .get,
            headers: headers
        ).responseDecodable(of: [Friendship].self) { (response) in
            guard let response = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(response))
        }
    }
    
    static func searchUsers(username: String, completion: @escaping SearchedUsersCompletion) {
        friendsService.getFriendshipRequests(type: .outgoing) { result in
            switch result {
            case .success(let requests):
                Self.searchUsers(username: username, friendsipRequests: requests, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func searchUsers(username: String, friendsipRequests: [FriendshipRequest], completion: @escaping SearchedUsersCompletion) {
        guard let authorizationHeader = Self.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "query": username
        ]
        
        _ = AF.request(
            Endpopints.searchUsersComponents.url!,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: [User].self) { (response) in
            guard let users = response.value  else {
                completion(.failure(.parsingResponse))
                return
            }
            searchUsers(users: users, friendsipRequests: friendsipRequests,completion: completion)
        }
    }
    
    private static func searchUsers(users: [User], friendsipRequests: [FriendshipRequest], completion: @escaping SearchedUsersCompletion) {
        getFriendships { result in
            switch result {
            case .success(let friendships):
                let searchedUsers = users.map { user in
                    let friendship = friendships.first { friendship in
                        friendship.user1 == user || friendship.user2 == user
                    }
                    var friendshipRequest: FriendshipRequest? = nil
                    if friendship == nil {
                        friendshipRequest = friendsipRequests.first { request in
                            request.recipient == user
                        }
                    }
                    return SearchedUser(
                        user: user,
                        friendshipRequest: friendshipRequest,
                        friendship: friendship
                    )
                }
                completion(.success(searchedUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension UsersService {
    
    enum UsersError: Error {
        case wrongCreds
        case parsingResponse
        case unknown
    }
}
