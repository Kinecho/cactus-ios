//
//  NotificationTimeOfDayViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
class NotificationTimeOfDayViewController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timezoneLabel: UILabel!
    
    @IBOutlet weak var timezoneWarningStackView: UIStackView!
    @IBOutlet weak var timeZoneWarningLabel: UILabel!
    @IBOutlet weak var updateTimeZoneButton: PrimaryButton!
    
    let logger = Logger("NotificationTimeOfDayViewController")
    var memberUnsubscriber: Unsubscriber?
    var member: CactusMember? = CactusMemberService.sharedInstance.currentMember
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureTimezone()
        self.configureDatePicker()
        self.configureTimeZoneWarningStackView()
        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, _) in
            if let error = error {
                self.logger.error("Failed to observe cactus member", error)
            }
            
            guard let member = member else {
                return
            }
            
            self.member = member
            self.configureTimezone()
            self.configureDatePicker()
        })
        
    }

    func configureTimeZoneWarningStackView() {
        self.timezoneWarningStackView.addBackground(color: CactusColor.alertYellow, cornerRadius: 10)
    }
    
    func configureTimezone() {
        let deviceTzOffset = getDeviceTimeZone().secondsFromGMT()
        
        if let memberTzOffset = self.member?.getPreferredTimeZone()?.secondsFromGMT(), memberTzOffset != deviceTzOffset {
            let warningBase = "It looks like you're in a different time zone than usual. Would you like to update"
            var warningAttributed = NSAttributedString(string: warningBase)
            if let tzName = getTimeZoneGenericName(getDeviceTimeZone()) {
                warningAttributed = NSAttributedString(string: "\(warningBase) to \(tzName)?".preventOrphanedWords()).withBold(forSubstring: tzName.preventOrphanedWords())
            } else {
                warningAttributed = NSAttributedString(string: "\(warningBase) it?".preventOrphanedWords())
            }
            
            self.timeZoneWarningLabel.attributedText = warningAttributed
            self.timezoneWarningStackView.isHidden = false
        } else {
            self.timezoneWarningStackView.isHidden = true
        }
        
        let tz = self.member?.getPreferredTimeZone() ?? Calendar.current.timeZone        
        let tzText = "\(getTimeZoneGenericName(tz) ?? "") "
        
        self.timezoneLabel.text = tzText
    }
    
    @IBAction func timePickerEditingDidEnd(_ sender: Any) {
        
        let date = self.timePicker.date
        let calendar = getMemberCalendar(member: self.member)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        guard let member = self.member else {
            self.logger.warn("No current member found, can't update time preference")
            return
        }
        let sendTime = PromptSendTime(hour: hour, minute: minute)
        member.promptSendTime = sendTime
        CactusMemberService.sharedInstance.save(member, completed: {_, error in
            if let error = error {
                self.logger.error("Failed to save member's preferred promptSentTime", error)
            }
//            self.configureDatePicker()
        })
//        self.configureDatePicker()
    }
    
    func configureDatePicker() {
        guard let defaultDate = getDefaultNotificationDate(member: self.member) else {return}
        self.timePicker.minuteInterval = 15
        self.timePicker.setDate(defaultDate, animated: true)
//        self.timePicker.delega
    }
   
    @IBAction func udpateTimeZoneTapped(_ sender: Any) {
        guard let member = self.member else {
            self.logger.warn("no mamber was found on the view controller. Can not update timezone")
            return
        }
        
        let tz = getDeviceTimeZone().identifier
        member.timeZone = tz
        CactusMemberService.sharedInstance.save(member) { (_, error) in
            if let error = error {
                self.logger.error("Failed to update the member's timezone", error)
            }
            self.configureTimezone()
            self.configureDatePicker()
        }
        
    }
    
}
