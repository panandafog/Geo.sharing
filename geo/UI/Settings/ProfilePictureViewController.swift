//
//  ProfilePictureViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

class ProfilePictureViewController: UIViewController, NotificatingViewController {
    
    private let authorizationService = AuthorizationService.shared
    private let usersService = UsersService.self
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateImage()
    }
    
    @IBAction private func selectImageButtonTouched(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    private func setupStyling() {
        navigationItem.title = "Profile picture"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func updateImage() {
        guard let userID = authorizationService.uid else {
            return
        }
        usersService.getProfilePicture(userID: userID) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            case .failure(let error):
                self?.showErrorAlert(error)
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage.emptyProfilePicture
                }
            }
        }
    }
}

extension ProfilePictureViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        usersService.setProfilePicture(image) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
                self?.updateImage()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
}

extension ProfilePictureViewController: UINavigationControllerDelegate {
    
}
