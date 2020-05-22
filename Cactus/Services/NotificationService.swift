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
import FirebaseInAppMessaging

class NotificationService: NSObject {
    let gcmMessageIDKey = "gcm.message_id"
    let firestoreService: FirestoreService
    let notificationCenter = NotificationCenter.default
    let logger = Logger("NotificationService")
    var fcmToken: String?
    
    public static var sharedInstance: NotificationService!
    
    static func start(application: UIApplication) {
        NotificationService.sharedInstance = NotificationService()
        NotificationService.sharedInstance.clearIconBadge()
        NotificationService.sharedInstance.registerForPushIfEnabled(application: application)
    }
    
    private override init() {
        self.firestoreService = FirestoreService.sharedInstance
        super.init()
        self.notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        Messaging.messaging().delegate = self
        let inAppDelegate = FirebaseInAppMessageDelegate()
        inAppDelegate.fetchId()
        InAppMessaging.inAppMessaging().delegate = inAppDelegate
            
    }
    
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
                    if #available(iOS 10.0, *) {
                        // For iOS 10 display notification (sent via APNS)
                        UNUserNotificationCenter.current().delegate = self
                        
                        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                        UNUserNotificationCenter.current().requestAuthorization(
                            options: authOptions,
                            completionHandler: {success, error in
                                self.logger.info("Register for notifications permissions: bool = \(success)")
                                if let error = error {
                                    self.logger.error("Failed to register for nofitications", error)
                                }
                        })
                    } else {
                        let settings: UIUserNotificationSettings =
                            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                        application.registerUserNotificationSettings(settings)
                    }
                    
                    application.registerForRemoteNotifications()
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
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        NavigationService.sharedInstance.openUrl(url: url)

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

// [START ios_10_message_handling]
@available(iOS 10, *)
extension NotificationService: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.logger.warn("Unable to register for remote notifications: \(error.localizedDescription)", functionName: #function, line: #line)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.logger.info("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.logger.debug("didReceiveRemoteNotification triggered line 243", functionName: #function, line: #line)
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            self.logger.debug("Message ID: \(messageID)", functionName: #function, line: #line)
        }
        
        // Print full message.
        self.logger.debug("Message Info: \(userInfo)", functionName: #function, line: #line)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.logger.info("didReceiveRemoteNotification triggered line 260", functionName: #function, line: #line)
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            self.logger.debug("Message ID: \(messageID)", functionName: #function, line: #line)
        }
        
        // Print full message.
        self.logger.debug("Message Info: \(userInfo)", functionName: #function, line: #line)
        if let promptContentEntryId = userInfo["promptEntryId"] as? String {
            AppDelegate.shared.rootViewController.loadPromptContent(promptContentEntryId: promptContentEntryId, link: nil)
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        self.logger.info("Receive displayed notificications for ios 10", functionName: #function, line: #line)
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            self.logger.debug("Message ID: \(messageID)", functionName: #function, line: #line)
        }
        
        // Print full message.
        self.logger.debug("Message Info: \(userInfo)", functionName: #function, line: #line)
        NotificationService.sharedInstance.handlePushMessage(userInfo)
        // Change this to your preferred presentation option
        if let promptContentEntryId = userInfo["promptEntryId"] as? String {
            AppDelegate.shared.rootViewController.loadPromptContent(promptContentEntryId: promptContentEntryId, link: nil)
        }
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        self.logger.info("User notification received", functionName: #function, line: #line)
        if let messageID = userInfo[gcmMessageIDKey] {
            self.logger.debug("Message ID: \(messageID)", functionName: #function, line: #line)
        }
        // Print full message.
        self.logger.debug("Message Info: \(userInfo)", functionName: #function, line: #line)
        
        if let promptContentEntryId = userInfo["promptEntryId"] as? String {
            AppDelegate.shared.rootViewController.loadPromptContent(promptContentEntryId: promptContentEntryId, link: nil)
        }
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension NotificationService: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        self.logger.info("\(Emoji.flame) Firebase registration token: \(fcmToken)")
        self.fcmToken = fcmToken
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]    
}

// swiftlint:disable force_cast
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: AppMainViewController {
        return window!.rootViewController as! AppMainViewController
    }
}
// swiftlint:enable force_cast
