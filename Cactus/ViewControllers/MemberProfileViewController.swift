//
//  MemberViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/27/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class MemberProfileViewController: UIViewController {

    @IBOutlet weak var fcmTokenLabel: UITextView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var cactusMemberIdLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fcmTokenLabel.text = AppDelegate.shared.fcmToken
        // Do any additional setup after loading the view.
        
        let member = CactusMemberService.sharedInstance.getCurrentMember()
        self.cactusMemberIdLabel.text = member?.id
        self.emailLabel.text = member?.email
        self.userIdLabel.text = member?.userId
        
        
    }
    

    @IBAction func logOutTapped(_ sender: Any) {
        AuthService.sharedInstance.logOut(self)
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
