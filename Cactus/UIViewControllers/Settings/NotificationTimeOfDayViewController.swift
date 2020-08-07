//
//  NotificationTimeOfDayViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
class NotificationTimeOfDayViewController: UIViewController {

    var timePicker = UIDatePicker()
    var toolBar = UIToolbar()
    
    @IBOutlet weak var pickerStackView: UIStackView!
    @IBOutlet weak var timezoneWarningStackView: UIStackView!
    @IBOutlet weak var timeZoneWarningLabel: UILabel!
    @IBOutlet weak var updateTimeZoneButton: PrimaryButton!
    @IBOutlet weak var sendTimeLabel: UILabel!
    
    let logger = Logger("NotificationTimeOfDayViewController")
    var memberUnsubscriber: Unsubscriber?
    var member: CactusMember? = CactusMemberService.sharedInstance.currentMember
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.initDatePicker()
//        self.pickerStackView.addArrangedSubview(self.timePicker)
//        self.view.addSubview(self.timePicker)
        self.configureTimezone()
        self.configureDatePicker()
        self.configureTimeZoneWarningStackView()
//        self.navigationItem.title = "Schedule"
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
            self.configureSendTimeLabel()
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
        
//        let tz = self.member?.getPreferredTimeZone() ?? Calendar.current.timeZone
//        let tzText = "\(getTimeZoneGenericName(tz) ?? "") "
        
    }
    
    @IBAction func showDatePicker(_ sender: UIButton) {
        var datePicker = self.timePicker
        guard let defaultDate = getDefaultNotificationDate(member: self.member) else {
            return
        }
        datePicker = UIDatePicker()
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.setDate(defaultDate, animated: false)
//        datePicker.addTarget(self, action: #selector(self.onDoneButton(_:)), for: .editingDidEnd)
        self.timePicker = datePicker
        self.view.addSubview(datePicker)

        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.onCancelClick(_:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))
        let spacer =  UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [cancelButton, spacer, doneButton]
        toolBar.sizeToFit()
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(toolBar)
        UIView.animate(withDuration: 0.2) {
            self.timePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
            self.toolBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50)
        }
    }
    
    @objc func onCancelClick(_ sender: Any) {
        self.dismissDatePicker()
    }
    
    func dismissDatePicker() {
        UIView.animate(withDuration: 0.1, animations: {
            self.timePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 300)
            self.toolBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 50)
        }, completion: { (_) in
            self.toolBar.removeFromSuperview()
            self.timePicker.removeFromSuperview()
        })
    }
    
    @objc func onDoneButtonClick(_ sender: Any) {
        self.saveNotificationTime()
        self.dismissDatePicker()
    }
    
    func saveNotificationTime() {
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
            self.configureSendTimeLabel()
        })
//        self.configureDatePicker()
    }
    
    func configureSendTimeLabel() {
        let date: Date?
        let calendar = getMemberCalendar(member: self.member)
        if let timePreference = self.member?.promptSendTime {
            date = calendar.date(bySettingHour: timePreference.hour, minute: timePreference.minute, second: 0, of: Date())
        } else {
            date = calendar.date(bySettingHour: 2, minute: 45, second: 0, of: Date())
        }
        
        guard let notificationDate = date else {
            return
        }
        let format = DateFormatter()
        format.dateFormat = "h:mm a"
        format.amSymbol = "am"
        format.pmSymbol = "pm"
        let tz = self.member?.getPreferredTimeZone() ?? Calendar.current.timeZone
        let label = "\(format.string(from: notificationDate)) \(getTimeZoneGenericName(tz) ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.sendTimeLabel.text = label
    }
    
    func initDatePicker() {
//        var timePicker = UIDatePicker(frame: CGRect(0, 0, 100, 100))
//        timePicker.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        timePicker.datePickerMode = .date
//        timePicker.maximumDate = Date.distantFuture
//        timePicker.minimumDate = Date.distantPast
//        self.timePicker = timePicker
//        self.timePicker.calendar =
//        self.timePicker.date = Date()
//        self.timePicker.calendar = Calendar.current
//        self.timePicker.minuteInterval = 15
//        self.timePicker.setDate(Date(), animated: false)
//        self.configureDatePicker()
    }
    
    func configureDatePicker() {
//        guard let defaultDate = getDefaultNotificationDate(member: self.member) else {return}
//        self.timePicker.calendar = Calendar.current
//        self.timePicker.setDate(defaultDate, animated: true)
//        self.timePicker.minuteInterval = 15
//        self.timePicker.datePickerMode = .time
    }
//
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
