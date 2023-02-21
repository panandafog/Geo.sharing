//
//  EmptyTableBackgroundView.swift
//  geo
//
//  Created by Andrey on 13.02.2023.
//

import SnapKit
import UIKit

class EmptyTableBackgroundView: UIView {
    
    private let titleLabel = UILabel()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(title: String?) {
        titleLabel.text = title
    }

    private func setupUI() {
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
    }
}
