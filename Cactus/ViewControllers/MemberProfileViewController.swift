//
//  MemberViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase

@IBDesignable
class MemberProfileViewController: UIViewController {
    @IBOutlet weak var emailLabel: UITextView!
    @IBOutlet weak var permissionSettingErrorLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var managePermissionsInSettings = false
    var notificationObserver: NSObjectProtocol?
    
    @objc func showJournal(sender: Any?) {
        AppDelegate.shared.rootViewController.pushScreen(ScreenID.JournalHome)
    }
    
    @IBAction func pushToggleTriggered(_ sender: Any) {
        let isOn = notificationSwitch.isOn
        
        if !self.managePermissionsInSettings && isOn {
            NotificationService.sharedInstance.requestPushPermissions { _ in
                DispatchQueue.main.async {
                    self.refreshPermissionsToggle(animated: true)
                }
            }
        } else {
            let message = "Notification settings are managed in the App's Settings."
            
            let alert = UIAlertController(title: "Manage Notifications", message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take Me There", style: .default, handler: { (_) in
                NotificationService.sharedInstance.goToSettings()
                self.refreshPermissionsToggle(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                self.refreshPermissionsToggle()
            }))
            self.present(alert, animated: true)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshPermissionsToggle()
    }
    
    deinit {
        if let notifObserver = self.notificationObserver {
              NotificationCenter.default.removeObserver(notifObserver)
        }
    }
    
    func refreshPermissionsToggle(animated: Bool=false) {
        self.notificationSwitch.isEnabled = true
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .provisional:
                    print("authorized")
                    self.notificationSwitch.setOn(true, animated: animated)
                    self.managePermissionsInSettings = true
                    self.permissionSettingErrorLabel.isHidden = false
                case .denied:
                    print("denied")
                    self.managePermissionsInSettings = true
                    self.notificationSwitch.setOn(false, animated: animated)
                    self.permissionSettingErrorLabel.isHidden = false
                case .notDetermined:
                    print("not determined, ask user for permission now")
                    self.managePermissionsInSettings = false
                    self.notificationSwitch.setOn(false, animated: animated)
                    self.permissionSettingErrorLabel.isHidden = true
                @unknown default:
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
            DispatchQueue.main.async {
                self.refreshPermissionsToggle()
            }
        }

        emailLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Do any additional setup after loading the view.
        
        let member = CactusMemberService.sharedInstance.getCurrentMember()
        self.emailLabel.text = member?.email
        
//        let journalItem = UIBarButtonItem(title: "Journal", style: .plain, target: self, action: #selector(self.showJournal(sender:)))
//        self.navigationItem.rightBarButtonItem = journalItem
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        AuthService.sharedInstance.logOut(self)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
