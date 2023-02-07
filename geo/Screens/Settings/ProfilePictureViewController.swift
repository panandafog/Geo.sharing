//
//  ProfilePictureViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class ProfilePictureViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyling()
    }
    
    private func setupStyling() {
        navigationItem.title = "Profile picture"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func selectImageButtonTouched(_ sender: UIButton) {
    }
}
