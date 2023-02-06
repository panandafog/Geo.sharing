//
//  FriendPinView.swift
//  geo
//
//  Created by Andrey on 03.02.2023.
//

import SnapKit
import UIKit

class FriendPinView: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    func setup(user: User?) {
        self.user = user
        titleLabel.text = user?.username ?? "..."
    }
    
    private func commonInit() {
//        titleLabel.text = user?.username ?? "!"
    }
}
