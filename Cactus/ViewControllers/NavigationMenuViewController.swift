//
//  NavigationMenuViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/1/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol NavigationMenuViewControllerDelegate: class {
    func closeMenu()
    func openMenu()
}

class NavigationMenuViewController: UIViewController {

    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var streakCountLabel: UILabel!
    @IBOutlet weak var reflectionCountLabel: UILabel!
    @IBOutlet weak var reflectionDurationLabel: UILabel!
    
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    
    weak var delegate: NavigationMenuViewControllerDelegate?
    
    let reflectionCount = 52
    let minutes = 241
    let streak = 94
    let countDiff = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resetNumbers()
        // Do any additional setup after loading the view.
    }

    func finishedClosing() {
        self.resetNumbers()
    }
    
    func finishedOpening() {
        self.animateNumbers()
    }
    
    func resetNumbers() {
        self.reflectionCountLabel.text = "\(max(0, reflectionCount - countDiff))"
        self.streakCountLabel.text = "\(max(0, streak - countDiff))"
        self.reflectionDurationLabel.text = "\(max(0, minutes - countDiff))"
    }
    
    func animateNumbers() {
        print("Animate numbers called")
        let durationMs: UInt32 = 750
        self.reflectionsCountProcess = CountProcess(minValue: 0, maxValue: reflectionCount, name: "ReflectionCount", threads: 3)
        self.reflectionsCountProcess?.duration = durationMs
        self.reflectionsCountProcess?.finish(valueChanged: { (value) in
            self.reflectionCountLabel.text = "\(value)"
        })
        
        self.minutesCountProcess = CountProcess(minValue: 0, maxValue: minutes, name: "Minutes", threads: 3)
        self.minutesCountProcess?.duration = durationMs
        self.minutesCountProcess?.finish(valueChanged: { (value) in
            self.reflectionDurationLabel.text = "\(value)"
        })
        
        self.streakCountProcess = CountProcess(minValue: 0, maxValue: streak, name: "Streak", threads: 3)
        self.streakCountProcess?.duration = durationMs
        self.streakCountProcess?.finish(valueChanged: { (value) in
            self.streakCountLabel.text = "\(value)"
        })
    }
    
    @IBAction func inviteTapped(_ sender: Any) {
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeMenu()
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
