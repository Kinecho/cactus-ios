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
    
    let firestoreService:FirestoreService;
    private init() {
        firestoreService = FirestoreService.sharedInstance
        
        
    }
    
    public static var sharedInstance = NotificationService()
    
    func registerForPushIfEnabled(){
        self.hasPushPermissions { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    AppDelegate.shared.registerForPushNotifications(UIApplication.shared)
                }
            }
        }
    }
    
    func hasPushPermissions(onPermissions: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            onPermissions(settings.authorizationStatus)
            
        }
    }
    
    func goToSettings(){
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)

    }
    
    func requestPushPermissions(onFinished: @escaping (Bool) -> Void){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {hasPermission, error in
            print("Has permission", hasPermission)
            self.registerForPushIfEnabled()
            onFinished(hasPermission)
        }
    }
    
}
