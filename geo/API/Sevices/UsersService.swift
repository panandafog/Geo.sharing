//
//  UsersService.swift
//  geo
//
//  Created by Andrey on 27.01.2023.
//

import Alamofire

class UsersService {
    
    typealias UsersCompletion = (Result<[User], RequestError>) -> Void
    typealias SearchedUsersCompletion = (Result<[SearchedUser], RequestError>) -> Void
    typealias FriendsipsCompletion = (Result<[Friendship], RequestError>) -> Void
    typealias ImageCompletion = (Result<UIImage, RequestError>) -> Void
    
    private let authorizationService: AuthorizationService
    private let friendsService: FriendsService
    
    init(authorizationService: AuthorizationService, friendsService: FriendsService) {
        self.authorizationService = authorizationService
        self.friendsService = friendsService
    }
    
    func getFriendships(completion: @escaping FriendsipsCompletion) {
        sendRequest(
            method: .get,
            url: Endpoints.getFriendsComponents.url!,
            requiresAuthorization: true,
            completion: completion
        )
    }
    
    func searchUsers(username: String, completion: @escaping SearchedUsersCompletion) {
        friendsService.getFriendshipRequests(type: .outgoing) { [weak self] result in
            switch result {
            case .success(let requests):
                self?.searchUsers(username: username, friendsipRequests: requests, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func searchUsers(username: String, friendsipRequests: [FriendshipRequest], completion: @escaping SearchedUsersCompletion) {
        let completionHandler: ((Result<[User], RequestError>) -> Void) = { [weak self] result in
            switch result {
            case .success(let users):
                self?.searchUsers(
                    users: users,
                    friendsipRequests: friendsipRequests,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        sendRequest(
            method: .post,
            url: Endpoints.searchUsersComponents.url!,
            requiresAuthorization: true,
            parameters: .init(
                parameters: [
                    "query": username
                ],
                encoding: .jsonBody
            ),
            completion: completionHandler
        )
    }
    
    private func searchUsers(users: [User], friendsipRequests: [FriendshipRequest], completion: @escaping SearchedUsersCompletion) {
        getFriendships { result in
            switch result {
            case .success(let friendships):
                let searchedUsers = users.map { user in
                    let friendship = friendships.first { friendship in
                        friendship.user1 == user || friendship.user2 == user
                    }
                    var friendshipRequest: FriendshipRequest?
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
    
    func setProfilePicture(_ image: UIImage, completion: @escaping EmptyCompletion) {
        guard let authorizationHeader = authorizationDelegate?.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(
                    imageData,
                    withName: "picture",
                    fileName: "picture",
                    mimeType: "image/jpg"
                )
            },
            to: Endpoints.profilePictureRequestComponents.url!,
            method: .post,
            headers: headers
        )
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .response { response in
            guard response.value != nil else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(()))
        }
    }
    
    func getProfilePicture(userID: String, completion: @escaping ImageCompletion) {
        guard let authorizationHeader = authorizationDelegate?.authorizationHeader else {
            return
        }
        let headers: HTTPHeaders = [
            authorizationHeader
        ]
        let parameters = [
            "user_id": userID
        ]
        
        _ = AF.request(
            Endpoints.profilePictureRequestComponents.url!,
            method: .get,
            parameters: parameters,
            headers: headers
        )
        .responseData { response in
            guard let data = response.data, let image = UIImage(data: data) else {
                completion(.failure(.parsingResponse))
                return
            }
            completion(.success(image))
        }
    }
}

extension UsersService: SendingRequestsService {
    var authorizationDelegate: AuthorizationDelegate? {
        authorizationService
    }
}
