//
//  SettingsViewController.swift
//  geo
//
//  Created by Andrey on 06.02.2023.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func resetPassword()
    func showProfilePictureEdit()
    func signOut()
}

class SettingsViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: SettingsViewControllerDelegate?
    private lazy var viewModel = SettingsViewModel(delegate: self)
      
    @IBOutlet private var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupStyling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        let entry = viewModel.settingGroups[indexPath.section].entries[indexPath.row]
        entry.action?()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let entry = viewModel.settingGroups[indexPath.section].entries[indexPath.row]
        return (entry.action == nil) ? nil : indexPath
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.settingGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.settingGroups[section].entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let entry = viewModel.settingGroups[indexPath.section].entries[indexPath.row]
        cell.setup(entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.settingGroups[section].title
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func showProfilePictureEdit() {
        coordinator?.showProfilePictureEdit()
    }
    
    func resetPassword() {
        coordinator?.resetPassword()
    }
    
    func signOut() {
        coordinator?.signOut()
    }
}
