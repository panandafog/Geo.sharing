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
    
    private lazy var deleteImageItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(startDeletingImage)
        )
        item.tintColor = .systemRed
        return item
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var selectImageButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
        updateProgress(viewModel.imageUploadProgress, animated: false)
        updateActivityIndicator(downloadInProgress: viewModel.isDownloadingImage)
        updateNavigationItem(userHasAvatar: viewModel.image != nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.downloadCurrentImage()
    }
    
    @IBAction private func selectImageButtonTouched(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = true
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.$image.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.imageView.image = output
            }
        }
        .store(in: &cancellables)
        viewModel.$userHasAvatar.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.updateNavigationItem(userHasAvatar: output)
            }
        }
        .store(in: &cancellables)
        viewModel.$imageUploadProgress.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.updateProgress(output)
            }
        }
        .store(in: &cancellables)
        viewModel.$isDownloadingImage.sink { [weak self] output in
            DispatchQueue.main.async {
                self?.updateActivityIndicator(downloadInProgress: output)
            }
        }
        .store(in: &cancellables)
    }
    
    private func setupStyling() {
        navigationItem.title = "Profile picture"
    }
    
    private func updateProgress(_ progress: Progress?, animated: Bool = true) {
        if let progress = progress {
            selectImageButton.isEnabled = false
            progressView.isHidden = false
            progressView.setProgress(
                Float(progress.fractionCompleted),
                animated: animated
            )
        } else {
            selectImageButton.isEnabled = true
            progressView.isHidden = animated
            progressView.setProgress(0.0, animated: false)
        }
    }
    
    private func updateActivityIndicator(downloadInProgress: Bool) {
        if downloadInProgress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func updateNavigationItem(userHasAvatar: Bool) {
        if userHasAvatar {
            navigationItem.rightBarButtonItems = [deleteImageItem]
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }
    
    @objc private func startDeletingImage() {
        let alert = UIAlertController(
            title: "Are you sure you want to delete your profile picture?",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in
                self?.deleteImage()
            }
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    private func deleteImage() {
        viewModel.deleteCurrentImage()
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
