//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 3/25/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FacebookCore
import FBSDKCoreKit

//* developers.facebook.com/docs/swift/appevents
typealias FacebookEvents = AppEvents
typealias FirebaseAnalytics = Analytics

enum UserProperty: String {
    case subscription_tier
}

class CactusAnalytics {
    static let shared = CactusAnalytics()
    let logger = Logger("CactusAnalytics")
    
    func setSubscriptionTier(member: CactusMember?) {
        FirebaseAnalytics.setUserProperty(member?.tier.rawValue ?? "none", forName: UserProperty.subscription_tier.rawValue)
    }
    
    func setUserId(_ userId: String?) {
        FirebaseAnalytics.setUserID(userId)
    }
    
    func pricingPageDisplay() {
        FirebaseAnalytics.logEvent(AnalyticsEventBeginCheckout, parameters: [:])
        FirebaseAnalytics.logEvent("display_pricing", parameters: [:])
    }
    
    func checkoutContinueTapped(subscriptionProduct: SubscriptionProduct) {
        FirebaseAnalytics.logEvent(AnalyticsEventSelectItem, parameters: [
            AnalyticsParameterItemListName: "Subscription Plans",
            AnalyticsParameterItems: [[
                AnalyticsParameterItemName: subscriptionProduct.appleProductId ?? "apple_unknown",
                AnalyticsParameterItemCategory: "subscription_product"
            ]]
        ])
    }
    
    func selectedPlan(subscriptionProduct: SubscriptionProduct) {
                FirebaseAnalytics.logEvent(AnalyticsEventSelectItem, parameters: [
            AnalyticsParameterItemListName: "Subscription Plans",
            AnalyticsParameterItems: [[
                AnalyticsParameterItemName: subscriptionProduct.appleProductId ?? "apple_unknown",
                AnalyticsParameterItemCategory: "subscription_product"
            ]]
        ])
    }
    
    /*
     @Deprecated This method no longer does anything as Firebase + revenuecat report revenue automatically
     */
    func purchaseCompleted(productEntry: ProductEntry?) {
        //no op
    }
    
    func sendLoginAnalyticsEvent(_ loginEvent: LoginEvent, screen: ScreenID?=nil, anonymousUpgrade: Bool = false) {
        var analyticsParams: [String: Any] = [AnalyticsParameterMethod: loginEvent.providerId ?? "unknown"]
        if let screen = screen {
            analyticsParams["screen"] = screen.name
        }
        
        if anonymousUpgrade {
            analyticsParams["anonyomousUpgrade"] = true
        }
        
        let providerId = loginEvent.providerId ?? "unknown provider"
        let email = loginEvent.email ?? "unknown"
        if loginEvent.isNewUser {
            self.logger.sentryInfo(":wave: \(email) signed up on iOS via \(providerId). Email: \(email)")
            FirebaseAnalytics.logEvent(AnalyticsEventSignUp, parameters: analyticsParams)
            self.logCompleteRegistrationFacebookEvent(registrationMethod: providerId)
        } else {
            self.logger.sentryInfo("\(email) logged in on iOS via \(providerId)")
            FirebaseAnalytics.logEvent(AnalyticsEventLogin, parameters: analyticsParams)
        }
    }
    
    func logCompleteRegistrationFacebookEvent(registrationMethod: String) {
        FacebookEvents.logEvent(.completedRegistration, valueToSum: 0.0, parameters: [
            FacebookEvents.ParameterName.registrationMethod.rawValue: registrationMethod,
            FacebookEvents.ParameterName.currency.rawValue: "USD",
        ])
    }
    
    func logBrowseElementSelected(_ element: CactusElement) {
        let analyticsParams: [String: Any] = [
            AnalyticsParameterItemListName: "Browse Elements",
            AnalyticsParameterItems: [
                [AnalyticsParameterItemName: element.rawValue,
                AnalyticsParameterItemCategory: "cactus_element"]
                ]
        ]
        
        FirebaseAnalytics.logEvent(AnalyticsEventSelectItem, parameters: analyticsParams)
    }
    
    func startFirstPrompt() {
        FirebaseAnalytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
    }
    
    func promptCompleted(promptContent: PromptContent?) {
        FirebaseAnalytics.logEvent("prompt_completed", parameters: nil)
        if let firstPromptEntryId = AppSettingsService.sharedInstance.currentSettings?.firstPromptContentEntryId, firstPromptEntryId == promptContent?.entryId {
            self.completedFirstPrompt()
            return
        }

    }
    
    func completedFirstPrompt() {
        FirebaseAnalytics.logEvent(AnalyticsEventTutorialComplete, parameters: nil)
    }
}
