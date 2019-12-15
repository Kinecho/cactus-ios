//
//  NotificationService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

class NotificationService {
    
    let firestoreService: FirestoreService
    let notificationCenter = NotificationCenter.default
    let logger = Logger("NotificationService")
    
    private init() {
        firestoreService = FirestoreService.sharedInstance
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    public static var sharedInstance = NotificationService()
    
    @objc func appMovedToForeground() {
        self.logger.debug("Notification service - app moved to foreground, removing badge count")
        self.clearIconBadge()
    }
    
    @objc func appMovedToBackground() {
        //test
    }
    
    func clearIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func registerForPushIfEnabled(application: UIApplication) {
        self.hasPushPermissions { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    AppDelegate.shared.registerForPushNotifications(application)
                }
            }
        }
    }
    
    func hasPushPermissions(onPermissions: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            onPermissions(settings.authorizationStatus)
            
        }
    }
    
    func goToSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)

    }
    
    func requestPushPermissions(onFinished: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {hasPermission, _ in
            self.logger.debug("Has permission \(hasPermission)")
            self.registerForPushIfEnabled(application: UIApplication.shared)
            onFinished(hasPermission)
        }
    }
    
    func handlePushMessage(_ message: [AnyHashable: Any]) {
        self.logger.info("Cactus Notification service is handling message \(message)")
        
    }
    
}
