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
    
    @Published var image: UIImage?
    @Published var userHasAvatar = false
    @Published var isDownloadingImage = false
    @Published var imageUploadProgress: Progress?
    
    private weak var delegate: ProfilePictureViewModelDelegate?
    
    init(delegate: ProfilePictureViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        self.authorizationService = container.resolve(AuthorizationService.self)!
        self.usersService = container.resolve(UsersService.self)!
    }
    
    func downloadCurrentImage() {
        guard let userID = authorizationService.uid else {
            return
        }
        isDownloadingImage = true
        usersService.getProfilePicture(userID: userID) { [weak self] result in
            self?.isDownloadingImage = false
            switch result {
            case .success(let image):
                self?.image = image
                self?.userHasAvatar = true
            case .failure:
                self?.image = UIImage.emptyProfilePicture
                self?.userHasAvatar = false
            }
        }
    }
    
    func setProfilePicture(image: UIImage) {
        usersService.setProfilePicture(
            image,
            progressHandler: { [weak self] progress in
                self?.imageUploadProgress = progress
            },
            completion: { [weak self] result in
                self?.imageUploadProgress = nil
                switch result {
                case .success:
                    self?.image = image
                    self?.userHasAvatar = true
                case .failure(let error):
                    self?.delegate?.handleError(error: error)
                }
            }
        )
    }
    
    func deleteCurrentImage() {
        isDownloadingImage = true
        usersService.deleteProfilePicture { [weak self] result in
            self?.isDownloadingImage = false
            switch result {
            case .success:
                self?.image = UIImage.emptyProfilePicture
                self?.userHasAvatar = false
            case .failure(let error):
                self?.userHasAvatar = true
                self?.delegate?.handleError(error: error)
            }
        }
    }
}
