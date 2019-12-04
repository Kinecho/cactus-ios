//
//  NavigationMenuViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/1/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseAuth
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

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    var member: CactusMember?
    var user: User?
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    weak var settingsTableVc: SettingsTableViewController?
    var memberUnsubscriber: Unsubscriber?
    
    weak var delegate: NavigationMenuViewControllerDelegate?
    
    var previousReflectionCount = 0
    var previousReflectionDurationMs = 0
    var previousStreak = 0
    
    var reflectionCount = 0 {
        didSet {
            self.animateReflectionCount()
            //            self.previousReflectionCount = newValue
        }
    }
    
    var reflectionDurationMs = 0 {
        didSet {
            self.animateDuration()
            //            self.previousReflectionDurationMs = newValue
        }
    }
    var streak = 0 {
        didSet {
            self.animateStreak()
            //            self.previousStreak = newValue
        }
    }
    let animationDurationMs: UInt32 = 600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reflectionCountLabel.text = "--"
        self.streakCountLabel.text = "--"
        self.reflectionDurationLabel.text = "--"
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height / 2
//        self.resetNumbers()
        // Do any additional setup after loading the view.
        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, user) in
            if let error = error {
                print("Failed to get member in NavMenu", error)
            }
            self.updateMemberInfo(member, user)
            self.member = member
            self.user = user
        })
    }
   
    deinit {
        self.memberUnsubscriber?()
    }
    
    func updateMemberInfo(_ member: CactusMember?, _ user: User?) {
        if let member = member {
            self.emailLabel.text = member.email
            self.emailLabel.isHidden = false
            self.displayNameLabel.text = "\(member.firstName ?? "") \(member.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
            self.displayNameLabel.isHidden = false
            
            if let reflectionStats = member.stats?.reflections {
                self.streak = reflectionStats.currentStreakDays
                self.reflectionDurationMs = reflectionStats.totalDurationMs
                self.reflectionCount = reflectionStats.totalCount
            }
            
            self.settingsTableVc?.member = member
            self.settingsTableVc?.configureView()
        } else {
            self.emailLabel.isHidden = true
            self.displayNameLabel.isHidden = true
        }
        
        if let avatarUrl = user?.photoURL {
            ImageService.shared.setFromUrl(self.avatarImageView, url: avatarUrl)
        } else {
            self.avatarImageView.image = CactusImage.avatar3.getImage()
        }
    }
    
    func finishedClosing() {
        self.resetNumbers()        
    }
    
    func finishedOpening() {
        self.animateNumbers()
    }
    
    func resetNumbers() {
        self.reflectionCountLabel.text = "--"
        self.streakCountLabel.text = "--"
        self.reflectionDurationLabel.text = "--"
    }
    
    func animateNumbers() {
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
                                                threads: 1)
        self.minutesCountProcess?.duration = animationDurationMs
        self.minutesCountProcess?.finish(valueChanged: { (value) in
            self.reflectionDurationLabel.text = "\(Double(value)/10)"
        }, completion: {value in
            DispatchQueue.main.async {
                self.reflectionDurationLabel.text = "\(Double(value)/10)"
            }            
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
//        let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.inviteScreen)
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let shareItem = InviteShareItem()
        var items: [Any] = [shareItem]
        if let shareURL = shareItem.getURL() {
            items.append(shareURL)
        }
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .openInIBooks]
        present(ac, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeMenu()
    }
    
    @IBAction func notificationsTapped(_ sender: Any) {
        let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.notificationsScreen)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.settingsTable)
        if let settingsVc = vc as? SettingsTableViewController {
            settingsVc.member = self.member
            self.settingsTableVc = settingsVc
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
