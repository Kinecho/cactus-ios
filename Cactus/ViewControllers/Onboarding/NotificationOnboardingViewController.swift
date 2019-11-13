//
//  NotificationOnboardingViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/13/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class NotificationOnboardingViewController: UIViewController {
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var deniedLabel: UILabel!
    @IBOutlet weak var enableLabel: UILabel!
    @IBOutlet weak var settingsButton: PrimaryButton!
    @IBOutlet weak var enableButton: PrimaryButton!
    @IBOutlet weak var authorizedLabel: UILabel!
    
    var logger = Logger(fileName: "NotificationOnboardingViewController")
    var status: UNAuthorizationStatus!
    var notificationObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notificationObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] _ in
            DispatchQueue.main.async {
                self.refreshPermission()
            }
        }
        
        if let authorizedText = self.authorizedLabel.attributedText {
            self.authorizedLabel.attributedText = authorizedText.withColor(CactusColor.darkestGreen).withItalics(forSubstring: "You can change this in your settings")            
        }
        
        if let deniedText = self.deniedLabel.attributedText {
            self.deniedLabel.attributedText = deniedText.withItalics(forSubstring: "You can enable this in your settings").withColor(CactusColor.darkestGreen)
        }
        
        self.configureView()
    }
    
    deinit {
        if let notifObserver = self.notificationObserver {
            NotificationCenter.default.removeObserver(notifObserver)
        }
    }
    
    func refreshPermission() {
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                self.status = status
                self.configureView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshPermission()
    }
    
    func configureView() {
        switch status {
        case .authorized:
            self.handleAuthorized()
        case .denied:
            self.handleDenied()
        case .notDetermined:
            self.handleNotDetermined()
        case .provisional:
            //todo: not sure if this is the right status
            self.handleNotDetermined()
        default:
            self.handleNotDetermined()
        }
    }
    
    func handleNotDetermined() {
        self.notificationTitleLabel.text = "Never miss a reflection"
        self.deniedLabel.isHidden = true
        self.authorizedLabel.isHidden = true
        self.enableLabel.isHidden = false
        self.settingsButton.isHidden = true
        self.enableButton.isHidden = false
    }
    
    func handleDenied() {
        self.notificationTitleLabel.text = "Notifications"
        self.deniedLabel.isHidden = false
        self.authorizedLabel.isHidden = true
        self.enableLabel.isHidden = true
        self.settingsButton.isHidden = false
        self.enableButton.isHidden = true
    }
    
    func handleAuthorized() {
        self.notificationTitleLabel.text = "Notifications"
        self.deniedLabel.isHidden = true
        self.enableLabel.isHidden = true
        self.authorizedLabel.isHidden = false
        self.settingsButton.isHidden = false
        self.enableButton.isHidden = true
    }

    @IBAction func settingsTapped(_ sender: Any) {
        NotificationService.sharedInstance.goToSettings()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func enableNotificationsTapped(_ sender: Any) {
        NotificationService.sharedInstance.requestPushPermissions { (isEnabled) in
            DispatchQueue.main.async {
                self.logger.info("User enabled notifications? \(isEnabled)")
                self.dismiss(animated: true)
            }
        }
    }
}
