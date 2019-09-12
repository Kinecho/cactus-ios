//
//  AppDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import FirebaseUI
import FirebaseMessaging
import Fabric
import Crashlytics
import Sentry

typealias SentryUser = Sentry.User

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var fcmToken: String?
    var window: UIWindow?
    private var currentUser:FirebaseAuth.User?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
       
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        Fabric.with([Crashlytics.self])
        
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: "https://728bdc63f41d4c93a6ce0884a01b58ea@sentry.io/1515431")
            
            try Client.shared?.startCrashHandler()
            Client.shared?.environment = CactusConfig.environment.rawValue
            let testEvent = Sentry.Event(level: .info)
            testEvent.message = "App Starting"
            testEvent.environment = CactusConfig.environment.rawValue
            testEvent.extra = ["ios": true]
            
            Client.shared?.send(event: testEvent)
        } catch let error {
            print("\(error)")
        }
        
        
        // Override point for customization after application launch.
        Auth.auth().addStateDidChangeListener(){auth, user in
            Analytics.logEvent("auth_state_changed", parameters: ["userId": user?.uid ?? "", "previousUserId": self.currentUser?.uid ?? ""])
            Crashlytics.sharedInstance().setUserEmail(user?.email)
            Crashlytics.sharedInstance().setUserIdentifier(user?.uid)
            Crashlytics.sharedInstance().setUserName(user?.displayName)
            if let user = user {
                let sentryUser = SentryUser(userId: user.uid)
                sentryUser.email = user.email
                Client.shared?.user = sentryUser;
                let loginEvent = Sentry.Event(level: .info);
                loginEvent.message = "\(user.email ?? user.uid) has logged in"
                Client.shared?.send(event: loginEvent)
            } else {
                
                if let currentUser = self.currentUser {
                    let logoutEvent = Sentry.Event(level: .info);
                    logoutEvent.message = "\(currentUser.email ?? currentUser.uid) has logged out of the app"
                    Client.shared?.send(event: logoutEvent)
                }
                Client.shared?.user = nil
            }
            self.currentUser = user;
        }

        
        Messaging.messaging().delegate = self
        
        NotificationService.sharedInstance.registerForPushIfEnabled()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationService.sharedInstance.registerForPushIfEnabled()
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
        
    //handle handler for result of URL signup flows
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        print("Starting application open url method (line 79)")
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            print("Handled by firebase auth ui")
            return true
        }
        // other URL handling goes here.
        print("handing custom link scheme", url )
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            print("handling dynamic link", dynamicLink)
            return true
        }
        
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.anecdotal") == .orderedSame,
            let viewName = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print("handling deep link:", viewName, parameters)
            
            //            redirect(to: view, with: parameters)
        }
        
        return false
    }
    
    //handle firebase dynamic links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("User activity webpageurl \(userActivity.webpageURL?.absoluteString ?? "none")")
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let error = error {
                print("error getting dynamic link", error)
            }
            print("handling dynamic link", dynamiclink ?? "No link found")
            guard let dynamiclink = dynamiclink, let url = dynamiclink.url else {return}
            
            let host = url.host
            let path = url.path
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print("host", host ?? "no host found")
            print("path", path)
            print("Parameters", parameters)
//            if let bookId = parameters["bookId"] {
//                let rootController = self.window?.rootViewController
//                if let invitationScreen = rootController?.storyboard?.instantiateViewController(withIdentifier: "invitationScreen") as? InvitationScreenViewController {
//                    invitationScreen.bookId = bookId
//
//
//                    if let presentedController = rootController?.presentedViewController {
//                        presentedController.present(invitationScreen, animated: true, completion: nil)
//                    }
//                    else {
//                        rootController?.present(invitationScreen, animated: true, completion: nil)
//                    }
//                }
//            }
        }
        print("link handled = \(handled)")
        return handled
    }
    
    //NOTE: See https://github.com/firebase/quickstart-ios/blob/master/messaging/MessagingExampleSwift/AppDelegate.swift
    func registerForPushNotifications(_ application: UIApplication){
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }

}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        self.fcmToken = fcmToken
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    
    // [END ios_10_data_message]
}


extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: AppMainViewController {
        return window!.rootViewController as! AppMainViewController
    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification triggered line 243")
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification triggered line 260")
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Receive displayed notificications for ios 10" )
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        print("User notification received")
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
}
// [END ios_10_message_handling]
