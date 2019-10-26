//
//  InviteSettingsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class InviteSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }
    
    func getShareLink() -> String {
        let member = CactusMemberService.sharedInstance.currentMember
        let email = member?.email ?? ""
        return "https://cactus.app?ref=\(email)&utm_source=cactus_ios&utm_medium=invite-friends"
    }
    
    func configureView() {
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let items = [URL(string: self.getShareLink()) as Any]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
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
