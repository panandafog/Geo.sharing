//
//  ImagesService.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import Kingfisher

class ImagesService {
    
    typealias ImageCompletion = (Result<UIImage, RequestError>) -> Void
    
    private let authorizationService: AuthorizationService
    
    init(authorizationService: AuthorizationService) {
        self.authorizationService = authorizationService
    }
    
    func getProfilePicture(userID: String, completion: @escaping ImageCompletion) {
        guard let authorizationHeader = authorizationDelegate?.authorizationHeader else {
            return
        }
        
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(authorizationHeader.value, forHTTPHeaderField: authorizationHeader.name)
            return request
        }
        
        var urlComponents = Endpoints.profilePictureRequestComponents
        urlComponents.queryItems = [
            URLQueryItem(name: "user_id", value: userID)
        ]
        
        KingfisherManager.shared.retrieveImage(
            with: urlComponents.url!,
            options: [.requestModifier(modifier)]
        ) { result in
            switch result {
            case .success(let retrieveResult):
                completion(.success(retrieveResult.image))
            case .failure(let error):
                completion(.failure(.parsingResponse))
            }
        }
    }
}

extension ImagesService: SendingRequestsService {
    var authorizationDelegate: AuthorizationDelegate? {
        authorizationService
    }
}
