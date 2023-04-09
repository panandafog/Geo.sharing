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
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupStyling()
        updateProgress(viewModel.imageUploadProgress, animated: false)
        updateActivityIndicator(downloadInProgress: viewModel.isDownloadingImage)
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
