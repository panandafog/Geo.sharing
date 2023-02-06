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
    
    private var user: User?
    private var titleLabel: UILabel!
    
    private let rect = CGRect(x: 0, y: 0, width: 80, height: 50)
    
    // MARK: Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel(frame: rect)
        titleLabel.backgroundColor = .tintColor
        addSubview(titleLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        user = (annotation as? FriendMKPointAnnotation)?.user
        titleLabel.text = user?.username ?? "..."
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()

        frame = rect
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
    }
}
