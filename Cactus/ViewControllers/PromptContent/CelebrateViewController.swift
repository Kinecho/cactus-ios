//
//  CelebrateViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/5/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class CelebrateViewController: UIViewController {

    @IBOutlet weak var encouragementLabel: UILabel!
    @IBOutlet weak var reflectionCountNumberLabel: UILabel!
    @IBOutlet weak var durationCountNumbereLabel: UILabel!
    @IBOutlet weak var streakNumberLabel: UILabel!
    @IBOutlet weak var durationMetricLabel: UILabel!
    @IBOutlet weak var reflectionCountMetricLabel: UILabel!
    @IBOutlet weak var homeButton: RoundedButton!
    let logger = Logger(fileName: "CelebrateViewController")
    var shouldAnimate = true
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    let animationDurationMs: UInt32 = 750
    var journalDataSource: JournalFeedDataSource?
    let celebrations = ["Well done!", "Nice work!", "Way to go!"]
    var memberUnsubscriber: Unsubscriber?
    var member: CactusMember? {
        didSet {
            self.logger.info("Member did set, animating numbers")
//            self.shouldAnimate = true
            self.animateNumbers()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let encouragement = celebrations.randomElement() ?? "Nice Work!"
        self.encouragementLabel.text = encouragement
        self.resetNumbers()
        self.shouldAnimate = false
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            self.member = member
        })
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        self.memberUnsubscriber?()
    }

    override func viewDidAppear(_ animated: Bool) {
        if self.shouldAnimate {
            self.animateNumbers()
            self.shouldAnimate = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.shouldAnimate = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.resetNumbers()
    }
    
    func resetNumbers() {
        self.reflectionCountNumberLabel.text = "--"
        self.streakNumberLabel.text = "--"
        self.durationCountNumbereLabel.text = "--"
    }
    
    func animateNumbers() {
        logger.info("Animating numbers")
        self.animateReflectionCount()
        self.animateDuration()
        self.animateStreak()
    }
    
    func animateReflectionCount() {
        let count = self.member?.stats?.reflections?.totalCount ?? 0
        self.reflectionsCountProcess = CountProcess(minValue: 0,
                                                    maxValue: count,
                                                    name: "ReflectionCount",
                                                    threads: 3)
        self.reflectionsCountProcess?.duration = animationDurationMs
        self.reflectionsCountProcess?.finish(valueChanged: { (value) in
            self.reflectionCountNumberLabel.text = "\(value)"
        })
    }
    
    func animateDuration() {
//        var prev = Int( round(Float(self.previousReflectionDurationMs) / 1000))
        let ms = self.member?.stats?.reflections?.totalDurationMs ?? 0
        var next = Int( round(Float(ms) / 1000))
        var prev: Int = 0
        if next < 60 {
            self.durationMetricLabel.text = "Seconds"
        } else {
            self.durationMetricLabel.text = "Minutes"
            next = Int(round(Float(next) * 10 / 60))
            prev = Int(round(Float(prev) * 10 / 60))
        }
        
        self.minutesCountProcess = CountProcess(minValue: prev,
                                                maxValue: next,
                                                name: "Duration",
                                                threads: 3)
        self.minutesCountProcess?.duration = animationDurationMs
        self.minutesCountProcess?.finish(valueChanged: { (value) in
            self.durationCountNumbereLabel.text = "\(Double(value)/10)"
        })
        
    }
    
    func animateStreak() {
        let count = self.member?.stats?.reflections?.currentStreakDays ?? 0
        self.streakCountProcess = CountProcess(minValue: 0,
                                               maxValue: count,
                                               name: "Streak",
                                               threads: 3)
        self.streakCountProcess?.duration = animationDurationMs
        self.streakCountProcess?.finish(valueChanged: { (value) in
            self.streakNumberLabel.text = "\(value)"
        })
    }
    
    @IBAction func goHomeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
