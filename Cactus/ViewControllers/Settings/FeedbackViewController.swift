//
//  FeedbackViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
class FeedbackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendEmail(_ sender: Any) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText = "Cactus%20\(appVersion ?? "")%20(\(buildVersion ?? "1"))"
        
        if let url = URL(string: "mailto:feedback@cactus.app?subject=iOS%20App%20Feedback%20for%20\(versionText)") {
            if #available(iOS 10.0, *) {
              UIApplication.shared.open(url)
            } else {
              UIApplication.shared.openURL(url)
            }
        }
    }
}
