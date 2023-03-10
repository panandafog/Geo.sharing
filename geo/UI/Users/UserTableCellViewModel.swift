//
//  UserTableCellViewModel.swift
//  geo
//
//  Created by Andrey on 20.02.2023.
//

import Swinject
import UIKit

class UserTableCellViewModel {
    let user: User
    let actions: [Action]
    
    init(user: User, actions: [Action]) {
        self.user = user
        self.actions = actions
    }
    
    func getProfilePicture(container: Container = .defaultContainer, completion: @escaping (UIImage?) -> Void) {
        container.resolve(ImagesService.self)?.getProfilePicture(userID: user.id) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func cancelGettingProfilePicture() {
        // TODO: cancel request
    }
}

extension UserTableCellViewModel {
    
    struct Action {
        let actionType: ActionType
        let action: ((UIAction) -> Void)
    }
    
    enum ActionType {
        case showOnMap
        case addFriend
        case removeFriend
        case deleteRequest
        
        var title: String {
            switch self {
            case .showOnMap:
                return "Show on map"
            case .addFriend:
                return "Add friend"
            case .removeFriend:
                return "Remove friend"
            case .deleteRequest:
                return "Delete friend request"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .showOnMap:
                return UIImage(systemName: "location.square")?.withTintColor(color, renderingMode: .alwaysOriginal)
            case .addFriend:
                return UIImage(systemName: "person.badge.plus")?.withTintColor(color, renderingMode: .alwaysOriginal)
            case .removeFriend:
                return UIImage(systemName: "person.fill.xmark.rtl")?.withTintColor(color, renderingMode: .alwaysOriginal)
            case .deleteRequest:
                return UIImage(systemName: "person.fill.xmark.rtl")?.withTintColor(color, renderingMode: .alwaysOriginal)
            }
        }
        
        var color: UIColor {
            switch self {
            case .showOnMap:
                return .tintColor
            case .addFriend:
                return .tintColor
            case .removeFriend:
                return .systemRed
            case .deleteRequest:
                return .systemRed
            }
        }
    }
}
