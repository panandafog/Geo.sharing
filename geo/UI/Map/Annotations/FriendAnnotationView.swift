//
//  FriendAnnotationView.swift
//  geo
//
//  Created by Andrey on 02.02.2023.
//

import MapKit
import SnapKit
import Swinject
import UIKit

class FriendAnnotationView: MKAnnotationView {
    
    private static let size = 60.0
    private static let border = 5.0
    private static let contentSize = size - (border * 2.0)
    
    private static let cornerRadius = 10.0
    private static let contentCornerRadius = cornerRadius - border / 2.0
    
    private var user: User? {
        (annotation as? FriendMKPointAnnotation)?.user
    }
    
    private var titleLabel: UILabel?
    private var imageView: UIImageView?
    
    private let rect = CGRect(x: 0, y: 0, width: size, height: size)
    private let contentRect = CGRect(
        x: border,
        y: border,
        width: contentSize,
        height: contentSize
    )
    
    // MARK: Initialization
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .tintColor
        layer.cornerRadius = Self.cornerRadius
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        setupLabel()
        setupImageView()
        
        if let user = (annotation as? FriendMKPointAnnotation)?.user {
            canShowCallout = true
            detailCalloutAccessoryView = FriendCalloutView(user: user)
        } else {
            canShowCallout = false
            detailCalloutAccessoryView = nil
        }
    }
    
    private func setupLabel() {
        let titleLabel = UILabel(frame: contentRect)
        titleLabel.text = user?.username ?? "..."
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = Self.contentCornerRadius
        
        addSubview(titleLabel)
        self.titleLabel = titleLabel
    }
    
    private func setupImageView() {
        let imageView = UIImageView(frame: contentRect)
        imageView.isHidden = true
        imageView.layer.cornerRadius = Self.contentCornerRadius
        imageView.layer.masksToBounds = true
        
        addSubview(imageView)
        self.imageView = imageView
        
        guard let user = user else {
            return
        }
        
        Container.defaultContainer.resolve(ImagesService.self)!.getProfilePicture(userID: user.id) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageView?.image = image
                self?.imageView?.isHidden = false
                self?.titleLabel?.isHidden = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        frame = rect
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }
}
