//
//  NotificationsTableViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var pushTimeOfDayLabel: UILabel!
    @IBOutlet weak var pushErrorLabel: UILabel!
    @IBOutlet weak var timeOfDayCell: UITableViewCell!
    var member: CactusMember? {
        didSet {
            self.updateEmailSwitch(animated: true)
        }
    }
    
    var notificationObserver: NSObjectProtocol?
    var managePermissionsInSettings = false
    var memberUnsubscriber: Unsubscriber?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.updateNotificationTime()
        self.notificationObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
            DispatchQueue.main.async {
                self.refreshPermissionsToggle()
            }
        }
        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, _) in
            if let error = error {
                print("error fetching member \(error)")
            }
            self.member = member
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshPermissionsToggle()
        self.updateEmailSwitch()
        self.updateNotificationTime()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateNotificationTime() {
        guard let denverDate = getDenverCalendar().date(bySettingHour: 2, minute: 45, second: 0, of: Date()) else {return}
        let format = DateFormatter()
        format.dateFormat = "H:mm aa"
        self.pushTimeOfDayLabel.text = format.string(from: denverDate)
    }
    
    func updateEmailSwitch(animated: Bool = false) {
        guard let member = self.member else {return}
        let emailStatus = member.notificationSettings?["email"] ?? "NOT_SET"
        if emailStatus == "ACTIVE" {
            self.emailSwitch.setOn(true, animated: animated)
        } else {
            self.emailSwitch.setOn(false, animated: animated)
        }
    }
    
    deinit {
        if let notifObserver = self.notificationObserver {
            NotificationCenter.default.removeObserver(notifObserver)
        }
        
        self.memberUnsubscriber?()
    }
    
    @IBAction func pushToggleTriggered(_ sender: Any) {
        let isOn = pushSwitch.isOn
        
        if !self.managePermissionsInSettings && isOn {
            NotificationService.sharedInstance.requestPushPermissions { _ in
                DispatchQueue.main.async {
                    self.refreshPermissionsToggle(animated: true)
                }
            }
        } else {
            let message = "Notification settings are managed in the App's Settings."
            
            let alert = UIAlertController(title: "Manage Notifications", message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Go to App Settings", style: .default, handler: { (_) in
                NotificationService.sharedInstance.goToSettings()
                self.refreshPermissionsToggle(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                self.refreshPermissionsToggle()
            }))
            self.present(alert, animated: true)
            
        }
        
    }
    
    func refreshPermissionsToggle(animated: Bool=false) {
        self.pushSwitch.isEnabled = true
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .provisional:
                    print("authorized")
                    self.pushSwitch.setOn(true, animated: animated)
                    self.managePermissionsInSettings = true
                    self.pushErrorLabel.isHidden = false
                case .denied:
                    print("denied")
                    self.managePermissionsInSettings = true
                    self.pushSwitch.setOn(false, animated: animated)
                    self.pushErrorLabel.isHidden = false
                case .notDetermined:
                    print("not determined, ask user for permission now")
                    self.managePermissionsInSettings = false
                    self.pushSwitch.setOn(false, animated: animated)
                    self.pushErrorLabel.isHidden = true
                @unknown default:
                    break
                }
            }
        }
    }
    
}
