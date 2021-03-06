//
//  CelebrateViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/5/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import WebKit
import FirebaseFirestore

protocol CelebrateViewControllerDelegate: class {
    func goHome()
}

class CelebrateViewController: UIViewController {

    @IBOutlet weak var encouragementLabel: UILabel!
    @IBOutlet weak var reflectionCountNumberLabel: UILabel!
    @IBOutlet weak var durationCountNumberLabel: UILabel!
    @IBOutlet weak var streakNumberLabel: UILabel!
    @IBOutlet weak var durationMetricLabel: UILabel!
    @IBOutlet weak var reflectionCountMetricLabel: UILabel!
    @IBOutlet weak var homeButton: RoundedButton!
    @IBOutlet weak var needleBackgroundImageView: UIImageView!
    
    @IBOutlet weak var insightStackView: UIStackView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var insightsContainerView: UIView!
    
    @IBOutlet weak var insightsHeaderStackView: UIStackView!
    @IBOutlet weak var streakDurationLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var upsellContainer: UIView!
    @IBOutlet weak var upsellLabel: UILabel!
    @IBOutlet weak var upsellStackView: UIStackView!
    @IBOutlet weak var shareNoteButton: TertiaryButton!
    
    @IBOutlet weak var insightsTitleLabel: UILabel!
    @IBOutlet weak var insightsDescriptionLabel: UILabel!
    var insightsVc: MemberInsightsViewController?
    
    weak var reflectionResponse: ReflectionResponse? {
        didSet {
            self.configureShareNoteButton()
            self.configureInsights()
        }
    }
    var promptContent: PromptContent?
    var currentReflectionStats: ReflectionStats?
    let logger = Logger(fileName: "CelebrateViewController")
    var shouldAnimate = true
    var reflectionsCountProcess: CountProcess?
    var minutesCountProcess: CountProcess?
    var streakCountProcess: CountProcess?
    let animationDurationMs: UInt32 = 750
    let celebrations = ["Well done!", "Nice work!", "Way to go!"]
    var memberUnsubscriber: Unsubscriber?
    var appSettings: AppSettings? {
        didSet {
            DispatchQueue.main.async {
                self.configureInsights()
                self.configureUpsell()
            }
        }
    }
    var member: CactusMember? {
        didSet {
            self.logger.info("Member did set, animating numbers. Stats are: \(String(describing: member?.stats?.reflections))")
            self.animateNumbers()
            self.currentReflectionStats = member?.stats?.reflections
        }
    }
    
    weak var delegate: CelebrateViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let encouragement = celebrations.randomElement() ?? "Nice Work!"
        self.encouragementLabel.text = encouragement
        self.resetNumbers()
        self.shouldAnimate = false
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            self.member = member
            self.configureUpsell()
        })
                
        self.configureDescription()
        self.configureShareNoteButton()
        
        if UIScreen.main.bounds.width < 400 {
            self.mainStackView.spacing = 20
        } else {
            self.mainStackView.spacing = 40
        }
        
        self.createInsightsVC()        
        self.configureInsights()
    }
    
    deinit {
        self.memberUnsubscriber?()
    }
    
    func configureInsights() {
        guard isViewLoaded else {
            return
        }
        let showInsights = (self.appSettings?.insights?.celebrateInsightsEnabled ?? false)
        self.insightsVc?.reflectionResponse = self.reflectionResponse
        self.insightStackView.isHidden = !showInsights
        self.insightsVc?.appSettings = self.appSettings
        self.descriptionTextView.isHidden = showInsights
        self.encouragementLabel.isHidden = false
        
        self.insightsHeaderStackView.isHidden = isBlank(self.reflectionResponse?.content.text) || self.member?.tier == .BASIC
        
        self.insightsTitleLabel.text = (self.appSettings?.insights?.insightsTitle ?? "Today's Insight").uppercased()
        self.insightsDescriptionLabel.text = (self.appSettings?.insights?.insightsDescription ?? "A visualization of words that have come up recently in your reflections.")
        
    }
    
    func createInsightsVC() {
        let insightsVc = MemberInsightsViewController()
        insightsVc.reflectionResponse = self.reflectionResponse
        guard let subView = insightsVc.view else {
            return
        }
        self.insightsVc = insightsVc
        self.insightsContainerView.translatesAutoresizingMaskIntoConstraints = false
        insightsVc.willMove(toParent: self)
        insightsVc.view.frame = self.insightsContainerView.bounds
        
        self.addChild(insightsVc)
        self.insightsContainerView.addSubview(subView)
//        subView.backgroundColor = .clear
//        subView.isOpaque = false
        insightsVc.didMove(toParent: self)
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.topAnchor.constraint(equalTo: insightsContainerView.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: insightsContainerView.bottomAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: insightsContainerView.leadingAnchor).isActive = true
        subView.trailingAnchor.constraint(equalTo: insightsContainerView.trailingAnchor).isActive = true        
    }
    
    func configureUpsell() {
        guard isViewLoaded else {
            return
        }
        let copy = self.appSettings?.upgradeCopy?.celebrate
        if self.member?.subscription?.isActivated == true {
            self.upsellStackView.isHidden = true
            self.upsellContainer.isHidden = true
            return
        }
        
        if self.member?.subscription?.isInOptInTrial == true {
            let daysLeft = self.member?.subscription?.trialDaysLeft ?? 0
            if daysLeft <= 1 {
                self.upsellLabel.text = "Free access to Cactus Plus ends today"
            } else {
                self.upsellLabel.text = "\(daysLeft) days left of free Cactus Plus access"
            }
        } else {
            self.upsellLabel.attributedText = MarkdownUtil.toMarkdown(copy?.upgradeBasicDescriptionMarkdown ?? "Get daily inishgts and more", color: CactusColor.white)
        }
        
        let imageView = UIImageView(image: CactusImage.plusBg.getImage())
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        self.upsellStackView.insertSubview(imageView, at: 0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.upsellStackView.topAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        imageView.leadingAnchor.constraint(equalTo: self.upsellStackView.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.upsellStackView.trailingAnchor, constant: 0).isActive = true
        self.upsellStackView.isHidden = false
        self.upsellContainer.isHidden = false
    }
    
    @IBAction func learnMoreTapped(_ sender: Any) {
        learnMoreAboutUpgradeTapped(target: self)
    }
    func configureShareNoteButton() {
        guard self.isViewLoaded else {return}
        
        if FormatUtils.isBlank(self.reflectionResponse?.content.text) {
            self.shareNoteButton.isHidden = true
        } else {
            self.shareNoteButton.isHidden = false
        }
    }
    
    func configureDescription() {
        guard let element = self.reflectionResponse?.cactusElement else {
            self.descriptionTextView.isHidden = true
            return
        }
        let description = getElementDescription(element).lowercased()
        let fullDescription_md = "Today's reflection focused on **\(element.rawValue)**, which is about \(description)."
        self.descriptionTextView.attributedText = MarkdownUtil.centeredMarkdown(fullDescription_md, font: CactusFont.normal(18), color: CactusColor.textMinimized)
        self.descriptionTextView.isHidden = false
    }
        
    func showElementModal(element: CactusElement) {
        logger.info("Showing element modal for \(element.rawValue)")
        guard let contentVc = ScreenID.elementsPageView.getViewController() as? CactusElementPageViewController else {return}
        contentVc.initialElement = element
        
        let modalVc = ModalViewController()
        modalVc.contentVc = contentVc
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
        self.present(modalVc, animated: true, completion: nil)
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
        self.durationCountNumberLabel.text = "--"
    }
    
    func animateNumbers() {
        logger.info("Animating numbers")
        self.animateReflectionCount()
        self.animateDuration()
        self.animateStreak()
    }
    
    func animateReflectionCount() {
        let previous = self.currentReflectionStats?.totalCount
        let count = self.member?.stats?.reflections?.totalCount ?? 0
        if previous == count {
            self.reflectionCountNumberLabel.text = "\(count)"
            return
        }
        self.reflectionsCountProcess = CountProcess(minValue: previous ?? 0,
                                                    maxValue: count,
                                                    name: "ReflectionCount",
                                                    threads: 3)
        self.reflectionsCountProcess?.duration = animationDurationMs
        self.reflectionsCountProcess?.finish(valueChanged: { (value) in
            self.reflectionCountNumberLabel.text = "\(value)"
        })
    }
   
    func animateDuration() {
        let ms = self.member?.stats?.reflections?.totalDurationMs ?? 0
        var next = Int( round(Float(ms) / 1000))
        var prev = self.currentReflectionStats?.totalDurationMs ?? 0
        if next < 60 {
            self.durationMetricLabel.text = "Seconds"
        } else {
            self.durationMetricLabel.text = "Minutes"
            next = Int(round(Float(next) * 10 / 60))
            prev = Int(round(Float(prev) * 10 / 60))
        }
        
        if self.currentReflectionStats?.totalDurationMs == ms {
            self.durationCountNumberLabel.text = "\(Double(next)/10)"
            return
        }
        
        self.minutesCountProcess = CountProcess(minValue: prev,
                                                maxValue: next,
                                                name: "Duration",
                                                threads: 3)
        self.minutesCountProcess?.duration = animationDurationMs
        self.minutesCountProcess?.finish(valueChanged: { (value) in
            self.durationCountNumberLabel.text = String(format: "%.0f", Double(value)/10)
        })
    }
    
    func animateStreak() {
        let previousCount = self.currentReflectionStats?.currentStreakInfo.count ?? 0
        let count = self.member?.stats?.reflections?.currentStreakInfo.count ?? 0
        if count == self.currentReflectionStats?.currentStreakInfo.count {
            self.streakNumberLabel.text = "\(count)"
            return
        }
        self.streakDurationLabel.text = (self.member?.stats?.reflections?.currentStreakInfo.duration ?? .DAYS).singularLabel + " Streak"
        self.streakCountProcess = CountProcess(minValue: previousCount,
                                               maxValue: count,
                                               name: "Streak",
                                               threads: 3)
        self.streakCountProcess?.duration = animationDurationMs
        self.streakCountProcess?.finish(valueChanged: { (value) in
            self.streakNumberLabel.text = "\(value)"
        })
    }
    
    @IBAction func goHomeTapped(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.goHome()
        } else {
            self.dismiss(animated: true, completion: nil)
        }        
    }
    
    @IBAction func shareNoteTapped(_ sender: Any) {
        let vc = ShareNoteViewController.loadFromNib()
        vc.reflectionResponse = self.reflectionResponse
        vc.promptContent = self.promptContent
        self.present(vc, animated: true)
    }
}
