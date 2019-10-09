//
//  EmailSettingsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class EmailSettingsViewController: UIViewController {

    @IBOutlet weak var emailTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupEmail()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupEmail()
    }
    
    func setupEmail() {
        if let member = CactusMemberService.sharedInstance.currentMember {
            self.emailTextView.text = member.email
        } else {
            self.emailTextView.text = "(none provided)"
        }
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
