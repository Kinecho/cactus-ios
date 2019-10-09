//
//  FeedbackViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import MessageUI
class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendEmail(_ sender: Any) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText = "Cactus \(appVersion ?? "") (\(buildVersion ?? "1"))"        
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["feedback@cactus.app"])
            mail.setSubject("iOS App Feedback for \(versionText)")
//            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Unable to open email client", message: "Please send us an email to feedback@cactus.app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Copy Email Address", style: .default, handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = "feedback@cactus.app"
            }))
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
//        if let url = URL(string: "mailto:feedback@cactus.app?subject=iOS%20App%20Feedback%20for%20\(versionText)") {
//            if #available(iOS 10.0, *) {
//              UIApplication.shared.open(url)
//            } else {
//              UIApplication.shared.openURL(url)
//            }
//        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
