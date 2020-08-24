//
//  HelpViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import MessageUI

class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var emailButton: PrimaryButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendEmail(_ sender: Any) {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            let versionText = "Cactus \(appVersion ?? "") (\(buildVersion ?? "1"))"
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["help@cactus.app"])
                mail.setSubject("Help for \(versionText)")

                present(mail, animated: true)
            } else {
                // show failure alert
                let alert = UIAlertController(title: "Unable to open email client", message: "Please send us an email to help@cactus.app", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Copy Email Address", style: .default, handler: { _ in
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = "help@cactus.app"
                }))
                alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }

}
