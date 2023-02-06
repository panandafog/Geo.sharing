//
//  SettingsViewController.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let authorizationService = AuthorizationService.shared
    var signOutHandler: (() -> Void)?
    
    lazy var settingGroups = [
        SettingsGroup(
            title: "Profile",
            entries: [
                SettingsEntry(
                    title: "Profile picture",
                    image: UIImage(systemName: "person.crop.rectangle"),
                    iconColor: .tintColor,
                    action: nil
                ),
                SettingsEntry(
                    title: "Username",
                    image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"),
                    iconColor: .tintColor,
                    action: nil
                ),
                SettingsEntry(
                    title: "Email",
                    image: UIImage(systemName: "envelope"),
                    iconColor: .tintColor,
                    action: nil
                ),
                SettingsEntry(
                    title: "Password",
                    image: UIImage(systemName: "lock"),
                    iconColor: .tintColor,
                    action: nil
                ),
                SettingsEntry(
                    title: "Sign out",
                    image: UIImage(systemName: "person.fill.xmark"),
                    iconColor: .systemRed,
                    action: { [weak self] in
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        self?.signOutHandler?()
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
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        let entry = settingGroups[indexPath.section].entries[indexPath.row]
        entry.action?()
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
        let title: String?
        let image: UIImage?
        let iconColor: UIColor?
        let action: (() -> Void)?
    }
}
