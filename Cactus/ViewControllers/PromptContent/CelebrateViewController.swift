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
    @IBOutlet weak var elementStackView: UIStackView!
        
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var experienceStatImageView: UIImageView!
    @IBOutlet weak var meaningStatImageView: UIImageView!
    @IBOutlet weak var emotionsStatImageView: UIImageView!
    @IBOutlet weak var energyStatImageView: UIImageView!
    @IBOutlet weak var relationshipStatImageView: UIImageView!
    
    weak var reflectionResponse: ReflectionResponse?
    
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
            self.updateElements()
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
        
        self.initElements()
        self.configureDescription()
        
    }
    
    func configureDescription() {
        guard let element = self.reflectionResponse?.cactusElement else {
            self.descriptionTextView.isHidden = true
            return
        }
        let description = getElementDescription(element).lowercased()
        self.descriptionTextView.text = "Today's reflection focused on \(element.rawValue), which is about \(description)"
        self.descriptionTextView.isHidden = false
    }
    
    func initElements() {
        for element in CactusElement.allCases {
            let imageView = self.getElementImage(element)
            imageView.isUserInteractionEnabled = true
            switch element {
            case .meaning:
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showMeaningModal)))
            case .emotions:
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showEmotionModal)))
            case .experience:
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showExperienceModal)))
            case .energy:
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showEnergyModal)))
            case .relationships:
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showRelationshipsModal)))
            }
        }
    }
        
    func showElementModal(element: CactusElement) {
        logger.info("Showing element modal for \(element.rawValue)")
        guard let contentVc = AppDelegate.shared.rootViewController.getScreen(ScreenID.elementsPageView) as? CactusElementPageViewController else {return}
        contentVc.initialElement = element
        
        let modalVc = ModalViewController()
        modalVc.contentVc = contentVc
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
        self.present(modalVc, animated: true, completion: nil)
    }
    
    @objc func showEnergyModal() {
        self.showElementModal(element: .energy)
    }
    
    @objc func showMeaningModal() {
        self.showElementModal(element: .meaning)
    }
    
    @objc func showRelationshipsModal() {
        self.showElementModal(element: .relationships)
    }
    
    @objc func showEmotionModal() {
        self.showElementModal(element: .emotions)
    }
    
    @objc func showExperienceModal() {
        self.showElementModal(element: .experience)
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
    
    func updateElements() {
        guard let stats = self.member?.stats?.reflections?.elementAccumulation else {return}
        for element in CactusElement.allCases {
            self.configureElement(element, number: stats.getElement(element))
        }
    }
    
    func getElementImage(_ element: CactusElement) -> UIImageView {
        var imageView: UIImageView!
        switch element {
        case .meaning:
            imageView = self.meaningStatImageView
        case .emotions:
            imageView = self.emotionsStatImageView
        case .experience:
            imageView = self.experienceStatImageView
        case .energy:
            imageView = self.energyStatImageView
        case .relationships:
            imageView = self.relationshipStatImageView
        }
        return imageView
    }
    
    func configureElement(_ element: CactusElement, number: Int) {
        let imageView = getElementImage(element)
        logger.info("Configuring element for \(element.rawValue)")
        if number > 0 {
            imageView.image = element.getStatImage(number)
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
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
