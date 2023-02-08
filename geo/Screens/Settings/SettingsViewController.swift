//
//  SettingsViewController.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var signOutHandler: (() -> Void)?
    
    private let authorizationService = AuthorizationService.shared
    
    private lazy var profilePictureViewController: ProfilePictureViewController = {
        UIViewController.instantiate(name: "ProfilePictureViewController") as! ProfilePictureViewController
    }()
    
    private lazy var resetPasswordViewController: ResetPasswordViewController = {
        let vc = UIViewController.instantiate(name: "ResetPasswordViewController") as! ResetPasswordViewController
        vc.successCompletion = { [weak self] in
            DispatchQueue.main.async {
                vc.navigationController?.popViewController(animated: true)
            }
            self?.signOut()
        }
        return vc
    }()
    
    private lazy var settingGroups = [
        SettingsGroup(
            title: "Profile",
            entries: [
                SettingsEntry(
                    kind: .profilePicture,
                    value: nil,
                    action: { [weak self] in
                        self?.editProfilePicture()
                    }
                ),
                SettingsEntry(
                    kind: .username,
                    value: authorizationService.username,
                    action: nil
                ),
                SettingsEntry(
                    kind: .email,
                    value: authorizationService.email,
                    action: nil
                ),
                SettingsEntry(
                    kind: .password,
                    value: nil,
                    action: { [weak self] in
                        self?.resetPassword()
                    }
                ),
                SettingsEntry(
                    kind: .signOut,
                    value: nil,
                    action: { [weak self] in
                        self?.signOut()
                    }
                )
            ]
        )
    ]
    
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupStyling()
        
        table.reloadData()
    }
    
    private func setupTable() {
        table.register(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = true
    }
    
    private func setupStyling() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func editProfilePicture() {
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(self.profilePictureViewController, animated: true)
        }
    }
    
    private func resetPassword() {
        authorizationService.requestPasswordChange { [weak self] result in
            switch result {
            case .success(()):
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(
                        self!.resetPasswordViewController,
                        animated: true
                    )
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func signOut() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        signOutHandler?()
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        let entry = settingGroups[indexPath.section].entries[indexPath.row]
        entry.action?()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let entry = settingGroups[indexPath.section].entries[indexPath.row]
        return (entry.action == nil) ? nil : indexPath
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        settingGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingGroups[section].entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let entry = settingGroups[indexPath.section].entries[indexPath.row]
        cell.setup(entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settingGroups[section].title
    }
}

extension SettingsViewController {
    
    struct SettingsGroup {
        let title: String?
        let entries: [SettingsEntry]
    }
    
    struct SettingsEntry {
        let kind: EntryKind
        let value: String?
        let action: (() -> Void)?
    }
    
    enum EntryKind {
        case profilePicture
        case username
        case email
        case password
        case signOut
        
        var title: String {
            switch self {
            case .profilePicture:
                return "Profile picture"
            case .username:
                return "Username"
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .signOut:
                return "Sign out"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .profilePicture:
                return UIImage(systemName: "person.crop.rectangle")
            case .username:
                return UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
            case .email:
                return UIImage(systemName: "envelope")
            case .password:
                return UIImage(systemName: "lock")
            case .signOut:
                return UIImage(systemName: "person.fill.xmark")
            }
        }
        
        var iconColor: UIColor? {
            switch self {
            case .signOut:
                return .systemRed
            default:
                return .tintColor
            }
        }
    }
}
