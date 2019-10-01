//
//  NavigationMenuViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/1/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class NavigationMenuViewController: UIViewController {

    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func inviteTapped(_ sender: Any) {
        
    }
    
    @IBAction func notificationsTapped(_ sender: Any) {
//        let vc = MemberProfileViewController()
        let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.MemberProfile)
        self.present(vc, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
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
