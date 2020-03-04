//
//  MemberSubscriptionTest.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import XCTest

class MemberSubscriptionTest: XCTestCase {
    func testTrialMethods() {
        let cal = Calendar.current
        let today = Date()
        let base = cal.date(byAdding: .hour, value: 1, to: today)!
        let minus7 = cal.date(byAdding: .day, value: -7, to: base)
        let minus1 = cal.date(byAdding: .day, value: -1, to: base)
        let plus1 = cal.date(byAdding: .day, value: 1, to: base)
        let plus7 = cal.date(byAdding: .day, value: 7, to: base)
        
        
        print("today \(String(describing: today))")
        print("plus1 \(String(describing: plus1))")
        
        let trial = SubscriptionTrial()
        trial.startedAt = minus7
        
        trial.endsAt = cal.date(byAdding: .hour, value: 1, to: today);
        XCTAssertEqual(trial.daysLeft, 0)
        
        trial.endsAt = cal.date(byAdding: .hour, value: 1, to: plus1!);
        XCTAssertEqual(trial.daysLeft, 1)
        
        trial.endsAt = minus1
        
        XCTAssertTrue(!trial.isActivated)
        XCTAssertTrue(trial.trialEnded)
        XCTAssertEqual(trial.daysLeft, nil)
        
        trial.startedAt = minus1
        trial.endsAt = plus1
        XCTAssertTrue(!trial.trialEnded)
        XCTAssertTrue(!trial.isActivated)
        XCTAssertEqual(trial.daysLeft, 1)
        
        trial.endsAt = plus7
        XCTAssertEqual(trial.daysLeft, 7)
        
        trial.activatedAt = today
        XCTAssertTrue(trial.isActivated)
        XCTAssertTrue(trial.trialEnded)
        XCTAssertEqual(trial.daysLeft, nil)
        
        trial.endsAt = minus1
        ///trial ended is still false
        XCTAssertTrue(trial.trialEnded)
        XCTAssertEqual(trial.daysLeft, nil)
    }
    
    func testDefaultTrial() {
        var defaultTrial = SubscriptionTrial.getDefault()
        XCTAssertEqual(defaultTrial.isActivated, false)
        XCTAssertEqual(defaultTrial.daysLeft, 6)
        XCTAssertNotNil(defaultTrial.startedAt)
        XCTAssertNotNil(defaultTrial.endsAt)
        XCTAssertNil(defaultTrial.activatedAt)
        
        defaultTrial = SubscriptionTrial.getDefault(10)
        XCTAssertEqual(defaultTrial.daysLeft, 9)
    }
    
    func testMemberSubscriptionValues() {
        let subscription = MemberSubscription.getDefault()
        let today = Date()
        let cal = Calendar.current
        let minus7 = cal.date(byAdding: .day, value: -7, to: today)
//        let plus7 = cal.date(byAdding: .day, value: 7, to: today)
        
        XCTAssertEqual(subscription.trialDaysLeft, 6)
        XCTAssertEqual(subscription.isInTrial, true)
        XCTAssertEqual(subscription.isActivated, false)
        XCTAssertEqual(subscription.legacyConversion, false)
        XCTAssertNotNil(subscription.trial)
        XCTAssertEqual(subscription.tier, .PLUS)
        
        subscription.trial?.activatedAt = minus7
        XCTAssertTrue(subscription.isActivated)
        XCTAssertTrue(!subscription.isInTrial)
        XCTAssertTrue(subscription.trialDaysLeft == nil)
                
        subscription.tier = .BASIC
        XCTAssertTrue(!subscription.isActivated)
        XCTAssertTrue(!subscription.isInTrial)
        
        ///this is kinda weird- a subscription can be _not in trial_ but the trial may not have ended
        subscription.trial?.activatedAt = nil
        XCTAssertTrue(!subscription.isActivated)
        XCTAssertTrue(!subscription.isInTrial)
        XCTAssertTrue(!subscription.trial!.trialEnded)
        
        subscription.tier = .PREMIUM
        XCTAssertTrue(!subscription.isActivated)
        XCTAssertTrue(subscription.isInTrial)
        XCTAssertTrue(!subscription.trial!.trialEnded)
        
    }
}
