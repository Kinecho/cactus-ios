//
//  FirebaseInAppMessageDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 2/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging
import FirebaseInstanceID
class FirebaseInAppMessageDelegate: NSObject, InAppMessagingDisplayDelegate {
    let logger = Logger("FirebaseInAppMessageDelegate")
    
    func fetchId() {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                self.logger.error("INSTANCE ID Failed to get instance ID", error)
                return
            }
            self.logger.info("INSTANCE ID id = \(result?.instanceID ?? "unknown")")
            self.logger.info("INSTANCE ID token = \(result?.token ?? "unknown")")
        }
    }
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage, with action: InAppMessagingAction) {
        self.logger.info("Message clicked. Action = \(action.actionText ?? "unknown")")
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage, dismissType: FIRInAppMessagingDismissType) {
        self.logger.info("Message dismissed. Dismiss Type = \(dismissType.rawValue)")
    }
    
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        self.logger.info("Impression detected")
    }
    
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        self.logger.error("Display error", error)
    }
}
