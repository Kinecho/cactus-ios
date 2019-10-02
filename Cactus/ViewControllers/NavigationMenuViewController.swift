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
    @IBOutlet weak var minutesLabel: UILabel!
    
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    
    weak var delegate: NavigationMenuViewControllerDelegate?
    
    var previousReflectionCount = 0
    var previousReflectionDurationMs = 0
    var previousStreak = 0
    
    var reflectionCount = 0 {
        willSet {
//            self.previousReflectionCount = newValue
        }
        
        didSet {
            self.animateReflectionCount()
        }
    }
    
    var reflectionDurationMs = 0 {
        willSet {
//            self.previousReflectionDurationMs = newValue
        }
        didSet {
            self.animateDuration()
        }
    }
    var streak = 0 {
        willSet {
//            self.previousStreak = newValue
        }
        
        didSet {
            self.animateStreak()
        }
    }
    let animationDurationMs: UInt32 = 750
    //    let countDiff = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reflectionCountLabel.text = "--"
        self.streakCountLabel.text = "--"
        self.reflectionDurationLabel.text = "--"
        
//        self.resetNumbers()
        // Do any additional setup after loading the view.
    }
    
    func finishedClosing() {
        self.resetNumbers()
    }
    
    func finishedOpening() {
        self.animateNumbers()
    }
    
    func resetNumbers() {
        //        self.reflectionCountLabel.text = "\(max(0, reflectionCount - countDiff))"
        //        self.streakCountLabel.text = "\(max(0, streak - countDiff))"
        //        self.reflectionDurationLabel.text = "\(max(0, minutes - countDiff))"
        
//        self.reflectionCountLabel.text = "0"
//        self.streakCountLabel.text = "0"
//        self.reflectionDurationLabel.text = "0"
        
//        self.previousReflectionCount = self.reflectionCount
//        self.previousStreak = self.streak
//        self.previousReflectionDurationMs = self.reflectionDurationMs
        
    }
    
    func animateNumbers() {
        print("Animate numbers called")
        self.animateReflectionCount()
        self.animateDuration()
        self.animateStreak()
    }
    
    func animateReflectionCount() {
        
        self.reflectionsCountProcess = CountProcess(minValue: self.previousReflectionCount,
                                                    maxValue: self.reflectionCount,
                                                    name: "ReflectionCount",
                                                    threads: 3)
        self.reflectionsCountProcess?.duration = animationDurationMs
        self.reflectionsCountProcess?.finish(valueChanged: { (value) in
            self.reflectionCountLabel.text = "\(value)"
        })
    }
    
    func animateDuration() {
        var prev = Int( round(Float(self.previousReflectionDurationMs) / 1000))
        var next = Int( round(Float(self.reflectionDurationMs) / 1000))
        
        if next < 60 {
            self.minutesLabel.text = "Seconds"
        } else {
            self.minutesLabel.text = "Minutes"
            next = Int(round(Float(next) * 10 / 60))
            prev = Int(round(Float(prev) * 10 / 60))
        }
        
        self.minutesCountProcess = CountProcess(minValue: prev,
                                                maxValue: next,
                                                name: "Duration",
                                                threads: 3)
        self.minutesCountProcess?.duration = animationDurationMs
        self.minutesCountProcess?.finish(valueChanged: { (value) in
            self.reflectionDurationLabel.text = "\(Double(value)/10)"
        })
        
    }
    
    func animateStreak() {
        self.streakCountProcess = CountProcess(minValue: self.previousStreak,
                                               maxValue: self.streak,
                                               name: "Streak",
                                               threads: 3)
        self.streakCountProcess?.duration = animationDurationMs
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
        
        let navController = UINavigationController(rootViewController: vc)
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissView))
        
        self.present(navController, animated: true)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
