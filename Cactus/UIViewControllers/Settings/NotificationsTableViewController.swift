//
//  NotificationsTableViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import MessageUI

class NotificationsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var pushTimeOfDayLabel: UILabel!
    @IBOutlet weak var pushErrorLabel: UILabel!
    @IBOutlet weak var timeOfDayCell: UITableViewCell!
    weak var timeOfDayVc: NotificationTimeOfDayViewController?
    var member: CactusMember? {
        didSet {
            guard self.isViewLoaded else {
                return
            }
            DispatchQueue.main.async {
                self.timeOfDayVc?.member = self.member
                self.updateEmailSwitch(animated: true)
                self.updateNotificationTimeLabel()
            }
            
        }
    }
    
    var notificationObserver: NSObjectProtocol?
    var managePermissionsInSettings = false
    
    let logger = Logger("NotificationsTableViewController")
    let footerView: UIView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()        
        tableView.tableFooterView = footerView
        self.updateNotificationTimeLabel()
        self.notificationObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
            DispatchQueue.main.async {
                self.refreshPermissionsToggle()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.refreshPermissionsToggle()
        self.updateEmailSwitch()
        self.updateNotificationTimeLabel()
        
    }
    
    func updateNotificationTimeLabel() {
        guard self.isViewLoaded else {
            return
        }
        let date: Date?
        let calendar = getMemberCalendar(member: self.member)
        if let timePreference = self.member?.promptSendTime {
            date = calendar.date(bySettingHour: timePreference.hour, minute: timePreference.minute, second: 0, of: Date())
        } else {
            date = calendar.date(bySettingHour: 2, minute: 45, second: 0, of: Date())
        }
        
        guard let notificationDate = date else {
            return
        }
        let format = DateFormatter()
        format.dateFormat = "h:mm a"
        format.amSymbol = "am"
        format.pmSymbol = "pm"
        let tz = self.member?.getPreferredTimeZone() ?? Calendar.current.timeZone
        let frequency = member?.subscription?.tier.isPaidTier == true ? "Daily" : "Occasionally"
        let label = "\(frequency) at \(format.string(from: notificationDate)) \(getTimeZoneGenericNameShort(tz) ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.pushTimeOfDayLabel.text = label
    }
    
    func updateEmailSwitch(animated: Bool = false) {
        guard self.isViewLoaded, let member = self.member else {return}
        let emailStatus = member.notificationSettings?["email"] ?? "NOT_SET"
        if emailStatus == "ACTIVE" && !self.emailSwitch.isOn {
            self.emailSwitch.setOn(true, animated: animated)
        } else if emailStatus != "ACTIVE" && self.emailSwitch.isOn {
            self.emailSwitch.setOn(false, animated: animated)
        }
    }
    
    deinit {
        if let notifObserver = self.notificationObserver {
            NotificationCenter.default.removeObserver(notifObserver)
        }        
    }
    
    @IBAction func emailSettingsToggled(_ sender: Any) {
        let isOn = emailSwitch.isOn
        guard let email = self.member?.email else {
            self.logger.warn("No email found on cactus member. Can not update the email settings")
            return
        }
        
        let subscribed: ListMemberStatus = isOn ? .subscribed : .unsubscribed
        
        let request = EmailNotificationStatusRequest(email, status: subscribed)
        
        ApiService.sharedInstance.updateEmailSubscriptionStatus(request, completed: { response in
            DispatchQueue.main.async {
                if response.success {
                    self.logger.info("Successfully updated email notification settings")
                    self.updateEmailSwitch()
                    return
                }
                
                if response.isInComplianceState == true {
                    self.logger.warn("Member is in compliance state and can not update their subscription via the API.")
                    self.showError(message: "Cactus is unable to subscribe you to receive email notifications because you previously unsubscribed." +
                        " Please email help@cactus.app to resolve this issue.",
                                   showHelpEmail: true)
                    self.updateEmailSwitch()
                    return
                }
                
                guard let error = response.error else {
                    self.logger.error("An unexpected error occurred while updating the email response. " +
                        "The response was not successful but no error provided")
                    self.showError(message: "We were un able to update your email preferences at this time. " +
                        "If you continue to get this error, please try updating your settings on the Cactus website.")
                    self.updateEmailSwitch()
                    return
                }
                self.logger.error("Email Status Update API returned an error", error)
                self.showError(message: error.message ?? "We were unable to update your email preferences at this time. " +
                "If you continue to get this error, please try updating your settings on the Cactus website." )
                self.updateEmailSwitch()
            }
        })
    }
    
    func showError(title: String = "Oops! Unable to save email settings", message: String, showHelpEmail: Bool=false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        if showHelpEmail {
            alert.addAction(UIAlertAction(title: "Send Email", style: .default, handler: { _ in
                self.sendEmail(self)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendEmail(_ sender: Any) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText = "Cactus \(appVersion ?? "") (\(buildVersion ?? "1"))"
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["help@cactus.app"])
            mail.setSubject("Help for \(versionText)")
            //            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Unable to open email client", message: "Please send us an email to help@cactus.app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Copy Email Address", style: .default, handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = "help@cactus.app"
            }))
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        //        if let url = URL(string: "mailto:feedback@cactus.app?subject=iOS%20App%20Feedback%20for%20\(versionText)") {
        //            if #available(iOS 10.0, *) {
        //              UIApplication.shared.open(url)
        //            } else {
        //              UIApplication.shared.openURL(url)
        //            }
        //        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
            alert.popoverPresentationController?.sourceView = sender as? UIView
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
                case .authorized,
                     .provisional:
                    self.logger.debug("authorized", functionName: "refreshPermissionsToggle")
                    self.pushSwitch.setOn(true, animated: animated)
                    self.managePermissionsInSettings = true
                case .denied:
                    self.logger.debug("denied", functionName: "refreshPermissionsToggle")
                    self.managePermissionsInSettings = true
                    self.pushSwitch.setOn(false, animated: animated)
                case .notDetermined:
                    self.logger.debug("not determined, ask user for permission now", functionName: "refreshPermissionsToggle")
                    self.managePermissionsInSettings = false
                    self.pushSwitch.setOn(false, animated: animated)
                @unknown default:
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetNotificationTime", let destVc = segue.destination as? NotificationTimeOfDayViewController {
            self.timeOfDayVc = destVc
            destVc.member = self.member
        }
    }
    
}
