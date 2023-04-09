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
        
        table.rowHeight = UITableView.automaticDimension
        table.sectionFooterHeight = UITableView.automaticDimension
        table.sectionHeaderHeight = UITableView.automaticDimension
        
        table.reloadData()
    }
    
    private func setupTable() {
        table.register(UINib(nibName: "SettingsActionCell", bundle: nil), forCellReuseIdentifier: SettingsActionCell.defaultReuseIdentifier)
        table.register(UINib(nibName: "SettingsSwitcherCell", bundle: nil), forCellReuseIdentifier: SettingsSwitcherCell.defaultReuseIdentifier)
        
        table.delegate = self
        table.dataSource = self
        table.allowsSelection = true
    }
    
    private func setupStyling() {
        navigationItem.title = "Settings"
    }
    
    private func entry(_ indexPath: IndexPath) -> SettingsEntry {
        viewModel.settingGroups[indexPath.section].entries[indexPath.row]
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        
        let entry = entry(indexPath)
        if entry.isSelectable {
            entry.action?()
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let entry = entry(indexPath)
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
        let entry = entry(indexPath)
        var cell: UITableViewCell?
        
        if let actionEntry = entry as? SettingsActionEntry {
            let actionCell = tableView.dequeueReusableCell(
                withIdentifier: SettingsActionCell.defaultReuseIdentifier,
                for: indexPath
            ) as! SettingsActionCell
            actionCell.setup(actionEntry)
            cell = actionCell
        }
        
        if let switchEntry = entry as? SettingsSwitchEntry {
            let switcherCell = tableView.dequeueReusableCell(
                withIdentifier: SettingsSwitcherCell.defaultReuseIdentifier,
                for: indexPath
            ) as! SettingsSwitcherCell
            switcherCell.setup(switchEntry)
            cell = switcherCell
        }
        
        cell?.selectionStyle = entry.isSelectable ? .default : .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.settingGroups[section].headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        viewModel.settingGroups[section].footerTitle
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
