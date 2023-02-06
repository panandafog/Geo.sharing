//
//  FriendAnnotationView.swift
//  geo
//
//  Created by Andrey on 02.02.2023.
//

import MapKit
import SnapKit
import UIKit

class FriendAnnotationView: MKAnnotationView {
    
    // MARK: Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    func setupUI() {
        let user = (annotation as? FriendMKPointAnnotation)?.user
        
        frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        backgroundColor = .systemRed

        let view = UINib(nibName: "FriendPinView", bundle: nil).instantiate(withOwner: self, options: nil).first as! FriendPinView
        addSubview(view)

        view.frame = bounds
        view.setup(user: user)
        view.layoutSubviews()
        layoutSubviews()
    }
}
