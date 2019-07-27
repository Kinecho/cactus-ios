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

class MemberProfileViewController: UIViewController {
    
    @IBOutlet weak var fcmTokenLabel: UITextView!
    @IBOutlet weak var userIdLabel: UITextView!
    @IBOutlet weak var cactusMemberIdLabel: UITextView!
    @IBOutlet weak var emailLabel: UITextView!
    
    @IBOutlet weak var permissionSettingErrorLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var managePermissionsInSettings = false
    
    @objc func showJournal(sender:Any?){
        AppDelegate.shared.rootViewController.pushScreen(ScreenID.JournalFeed)
    }
    
    @IBAction func pushToggleTriggered(_ sender: Any) {
        let isOn = notificationSwitch.isOn
        
        
        if !self.managePermissionsInSettings && isOn {
            NotificationService.sharedInstance.requestPushPermissions{ hasPermission in
                DispatchQueue.main.async {
                    self.refreshPermissionsToggle(animated: true)
                }                
            }
        } else {
            let message = "Notification settings are managed in the App's Settings."
            
            let alert = UIAlertController(title: "Manage Notifications", message: message, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take Me There", style: .default, handler: { (action) in
                NotificationService.sharedInstance.goToSettings()
                self.refreshPermissionsToggle(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in
                self.refreshPermissionsToggle()
            }))
            self.present(alert, animated: true)
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshPermissionsToggle()
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
                    break
                case .denied:
                    print("denied")
                    self.managePermissionsInSettings = true
                    self.notificationSwitch.setOn(false, animated: animated)
                    self.permissionSettingErrorLabel.isHidden = false
                    break
                case .notDetermined:
                    print("not determined, ask user for permission now")
                    self.managePermissionsInSettings = false
                    self.notificationSwitch.setOn(false, animated: animated)
                    self.permissionSettingErrorLabel.isHidden = true
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            DispatchQueue.main.async {
                self.refreshPermissionsToggle()
            }
        }

        fcmTokenLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        userIdLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        cactusMemberIdLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        emailLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        
        self.fcmTokenLabel.text = AppDelegate.shared.fcmToken
        // Do any additional setup after loading the view.
        
        let member = CactusMemberService.sharedInstance.getCurrentMember()
        self.cactusMemberIdLabel.text = member?.id
        self.emailLabel.text = member?.email
        self.userIdLabel.text = member?.userId
        
        let journalItem = UIBarButtonItem(title: "Journal", style: .plain, target: self, action: #selector(self.showJournal(sender:)))
        
        self.navigationItem.rightBarButtonItem = journalItem
        
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                self.fcmTokenLabel.text  = result.token
            }
        }
        
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
