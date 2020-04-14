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
class CactusAnalytics {
    static let shared = CactusAnalytics()
    let logger = Logger("CactusAnalytics")
    
    func purchaseCompleted(productEntry: ProductEntry?) {
        let price = productEntry?.subscriptionProduct.priceCentsUsd ?? 0
        let priceString = formatPriceCents(price, currencySymbol: "")
        FacebookEvents.logEvent(FacebookEvents.Name.startTrial,
                                valueToSum: Double(price)/100,
                                parameters: ["currency": "USD",
                                             "predicted_ltv": priceString ?? "0.00",
                                             "value": priceString ?? "0.00"
        ])
        //Note: firebase automatically fires in app purchase events.
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
            logCompleteRegistrationFacebookEvent(registrationMethod: providerId)
        } else {
            self.logger.sentryInfo("\(email) logged in on iOS via \(providerId)")
            FirebaseAnalytics.logEvent(AnalyticsEventLogin, parameters: analyticsParams)
        }
    }
    
    func logCompleteRegistrationFacebookEvent(registrationMethod: String) {
        FacebookEvents.logEvent(.completedRegistration, parameters: [
            FacebookEvents.ParameterName.registrationMethod.rawValue: registrationMethod
        ])
    }
    
    func logBrowseElementSelected(_ element: CactusElement) {
        let member = CactusMemberService.sharedInstance.currentMember
        let analyticsParams: [String: Any] = [
            AnalyticsParameterContentType: "Browse Element",
            AnalyticsParameterContent: element.rawValue,
            "subscription_tier": member?.tier.rawValue ?? ""
        ]
        
        FirebaseAnalytics.logEvent(AnalyticsEventSelectContent, parameters: analyticsParams)
    }
}
