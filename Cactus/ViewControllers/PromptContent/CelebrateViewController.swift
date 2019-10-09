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
    @IBOutlet weak var streakNumberLabe: UILabel!
    @IBOutlet weak var durationMetricLabel: UILabel!
    @IBOutlet weak var reflectionCountMetricLabel: UILabel!
    @IBOutlet weak var homeButton: RoundedButton!
    var shouldAnimate = true
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    let animationDurationMs: UInt32 = 750
    var journalDataSource: JournalFeedDataSource?
    let celebrations = ["Well done!", "Nice work!", "Way to go!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let encouragement = celebrations.randomElement() ?? "Nice Work!"
        self.encouragementLabel.text = encouragement
        self.resetNumbers()
        // Do any additional setup after loading the view.
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
        self.streakNumberLabe.text = "--"
        self.durationCountNumbereLabel.text = "--"
    }
    
    func animateNumbers() {
        print("Animate numbers called")
        self.animateReflectionCount()
        self.animateDuration()
        self.animateStreak()
    }
    
    func animateReflectionCount() {
        print("animate reflection count")
        let count = self.journalDataSource?.totalReflections ?? 0
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
        let ms = self.journalDataSource?.totalReflectionDurationMs ?? 0
        var next = Int( round(Float(ms) / 1000))
        var prev:Int = 0
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
        print("animate streak")
        let count = self.journalDataSource?.currentStreak ?? 0
        self.streakCountProcess = CountProcess(minValue: 0,
                                               maxValue: count,
                                               name: "Streak",
                                               threads: 3)
        self.streakCountProcess?.duration = animationDurationMs
        self.streakCountProcess?.finish(valueChanged: { (value) in
            self.streakNumberLabe.text = "\(value)"
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
