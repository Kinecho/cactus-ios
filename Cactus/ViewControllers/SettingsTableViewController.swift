//
//  SettingsTableViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Sentry

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var emailAddressLabel: UILabel!
    
    var member: CactusMember?
    var footerView = UIView()
    var logoutButton = RoundedButton()
    let versionTitleLabel = UILabel()
    let versionTextView = UITextView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.setNeedsStatusBarAppearanceUpdate()
        self.configureFooter()
        
        self.tableView.tableFooterView = self.footerView
        
        self.configureView()
    }

    func configureView() {
        let name = "\(member?.firstName ?? "") \(member?.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        let email = member?.email
        if !FormatUtils.isBlank(name) && !FormatUtils.isBlank(email) {
            self.emailAddressLabel.text = "\(name) (\(email ?? ""))"
        } else {
            self.emailAddressLabel.text = member?.email
        }
    }
    
    func configureFooter() {
        let footerView = UIView(frame: CGRect(0, 0, 50, self.view.bounds.width))
                
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.borderRadius = 18
        logoutButton.backgroundColor = .white
        logoutButton.titleLabel?.font = CactusFont.normalBold
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = CactusColor.darkGreen.cgColor
        logoutButton.setTitleColor(CactusColor.darkGreen, for: .normal)
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        footerView.addSubview(logoutButton)
        footerView.addSubview(versionTextView)
        footerView.addSubview(versionTitleLabel)
        
        logoutButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20).isActive = true
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        versionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        versionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        versionTitleLabel.text = "Version"
        versionTextView.text = "Cactus \(appVersion ?? "") (\(buildVersion ?? "1"))"
        
        versionTextView.isScrollEnabled = false
        versionTextView.isEditable = false
        versionTextView.font = CactusFont.normal
        versionTextView.textColor = CactusColor.lightText
        versionTextView.textAlignment = .right
        versionTitleLabel.font = CactusFont.normal
        versionTitleLabel.textColor = CactusColor.lightText
        
        versionTitleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: versionTextView.leadingAnchor, constant: 20).isActive = true
        versionTitleLabel.centerYAnchor.constraint(equalTo: versionTextView.centerYAnchor).isActive = true
        
        versionTitleLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20).isActive = true
        versionTitleLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20).isActive = true
        versionTextView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20).isActive = true
        logoutButton.topAnchor.constraint(equalTo: versionTitleLabel.bottomAnchor, constant: 40).isActive = true
        
        self.footerView = footerView
        
        logoutButton.addTarget(self, action: #selector(self.logOutTapped(_:)), for: .primaryActionTriggered)
        
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        AuthService.sharedInstance.logOut(self)
    }
}
