//
//  FriendCalloutView.swift
//  geo
//
//  Created by Andrey on 15.02.2023.
//

import SnapKit
import UIKit

class FriendCalloutView: UIView {
    
    private let titleLabel = UILabel()
    private var user: User
    
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setupTitle()
    }
    
    private func setupTitle() {
        addSubview(titleLabel)
        titleLabel.text = user.username
        titleLabel.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
    }
}
