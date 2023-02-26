//
//  ProfilePictureViewModel.swift
//  geo
//
//  Created by Andrey on 23.02.2023.
//

import Combine
import Swinject
import UIKit

protocol ProfilePictureViewModelDelegate: AnyObject {
    func handleError(error: RequestError)
}

class ProfilePictureViewModel: ObservableObject {
    
    private let authorizationService: AuthorizationService
    private let usersService: UsersService
    
    @Published var image = UIImage.emptyProfilePicture
    
    private weak var delegate: ProfilePictureViewModelDelegate?
    
    init(delegate: ProfilePictureViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        self.authorizationService = container.resolve(AuthorizationService.self)!
        self.usersService = container.resolve(UsersService.self)!
    }
    
    func downloadCurrnetImage() {
        guard let userID = authorizationService.uid else {
            return
        }
        usersService.getProfilePicture(userID: userID) { [weak self] result in
            switch result {
            case .success(let image):
                self?.image = image
            case .failure:
                self?.image = UIImage.emptyProfilePicture
            }
        }
    }
    
    func setProfilePicture(image: UIImage) {
        usersService.setProfilePicture(image) { [weak self] result in
            switch result {
            case .success:
                self?.image = image
            case .failure(let error):
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
