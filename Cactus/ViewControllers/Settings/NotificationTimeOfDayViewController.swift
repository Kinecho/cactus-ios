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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureTimezone()
        self.setDefaultTime()
        // Do any additional setup after loading the view.
    }

    func configureTimezone() {
        let tz = Calendar.current.timeZone
        self.timezoneLabel.text = tz.localizedName(for: .generic, locale: nil)
    }
    
    @IBAction func timePickerEditingDidEnd(_ sender: Any) {
        self.setDefaultTime()
    }
    
    func setDefaultTime() {
        guard let defaultDate = getDefaultNotificationDate() else {return}
        self.timePicker.setDate(defaultDate, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
