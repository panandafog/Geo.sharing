//
//  ProfilePictureViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import Combine
import UIKit

class ProfilePictureViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    lazy var viewModel = ProfilePictureViewModel(delegate: self)
    
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.downloadCurrnetImage()
    }
    
    @IBAction private func selectImageButtonTouched(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$image.sink { [weak self] output in
            self?.imageView.image = output
        }
        .store(in: &cancellables)
    }
    
    private func setupStyling() {
        navigationItem.title = "Profile picture"
    }
}

extension ProfilePictureViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        viewModel.setProfilePicture(image: image)
    }
}

extension ProfilePictureViewController: UINavigationControllerDelegate {
    
}

extension ProfilePictureViewController: ProfilePictureViewModelDelegate {
    func handleError(error: RequestError) {
        showErrorAlert(error)
    }
}
