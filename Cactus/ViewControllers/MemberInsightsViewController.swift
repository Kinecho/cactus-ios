//
//  MemberInsightsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 3/5/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class MemberInsightsViewController: UIViewController {
    var member: CactusMember?
    var insightsWebView: InsightsWebViewViewController!
    var modalContainer: UIView?
    var unlockMessageLabel: UILabel?
    var unlockButton: PrimaryButton?
    var unlockTitleLabel: UILabel?
    var learnMoreButton: UIButton?
    var memberUnsubscriber: Unsubscriber?
    let logger = Logger("MemberInsightsViewController")
    var pricingVc: PricingViewController?
    var reflectionResponse: ReflectionResponse?
    var noReflectionTextLabel: UILabel?
    var noReflectionTextTitleLabel: UILabel?
    var noInsightView: UIView?
    var noReflectionLearnMoreButton: UIButton?
    
    var appSettings: AppSettings? {
        didSet {
            self.configureCopy()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.member = CactusMemberService.sharedInstance.currentMember
        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
            self.member = member
            self.insightsWebView.member = self.member
        })
    
        self.createWebView()
        
        self.insightsWebView.member = self.member
        
        self.createUpgradeModal()
        self.configureModal()
        self.insightsWebView.loadInsights()
        
        let hasText = !isBlank(self.reflectionResponse?.content.text)
        insightsWebView.chartEnabled = true
        self.showModal(hasText)
        if !hasText {
            self.createNoInsightView()
            self.noInsightView?.isHidden = false
        }
        
    }
    
    deinit {
        self.memberUnsubscriber?()
    }
    
    func configureModal() {
        let tier = self.member?.subscription?.tier ?? .BASIC
        self.learnMoreButton?.isHidden = tier.isPaidTier
        self.unlockButton?.isHidden = !tier.isPaidTier

        if tier.isPaidTier {
            self.modalContainer?.backgroundColor = CactusColor.dolphin
            self.unlockMessageLabel?.textColor = CactusColor.white
            self.unlockTitleLabel?.textColor = CactusColor.white
        } else {
            self.modalContainer?.backgroundColor = CactusColor.white
            self.unlockMessageLabel?.textColor = CactusColor.darkestGreen
            self.unlockTitleLabel?.textColor = CactusColor.darkestGreen
        }
        
        let revealMessage = self.appSettings?.insights?.revealInsightMessage ?? "Want to see Today's Insight?"
        let upgradeMessage = self.appSettings?.insights?.revealInsightUpgradeMessage ?? "To reveal Today's Insight, upgrade to Cactus Plus."
        
        let unlockText = self.appSettings?.insights?.revealInsightButtonText ?? "Show Me!"
        self.unlockButton?.setTitle(unlockText, for: .normal)
        self.unlockTitleLabel?.text = (self.appSettings?.insights?.insightsTitle ?? "Today's Insight").uppercased()
        self.noReflectionTextTitleLabel?.text = (self.appSettings?.insights?.insightsTitle ?? "Today's Insight").uppercased()
        self.unlockMessageLabel?.text = tier.isPaidTier ? revealMessage : upgradeMessage
        
        let upgradeButtonText = self.appSettings?.insights?.learnMoreButtonText ?? "What are insights?"
        self.learnMoreButton?.setTitle(upgradeButtonText, for: .normal)
        self.noReflectionLearnMoreButton?.setTitle( upgradeButtonText, for: .normal)
    }
    
    func configureCopy() {
        self.configureModal()
        self.noReflectionTextLabel?.text = appSettings?.insights?.noTextTodayMessage ?? "You didn't write anything today. That's fine, but Today's Insight only works when you capture your thoughts."
        self.noReflectionTextTitleLabel?.text = (appSettings?.insights?.noTextTodayTitle ?? "Today's Insight").uppercased()
    }
    
    func createWebView() {
        let webVc = InsightsWebViewViewController()
        self.insightsWebView = webVc
        webVc.willMove(toParent: self)
        
        self.addChild(webVc)
        self.view.addSubview(webVc.view)
        webVc.didMove(toParent: self)
        
        webVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        webVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        webVc.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        webVc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func createNoInsightView() {
        let container = UIView(frame: CGRect(0, 0, 100, 100))
        
        self.noInsightView = container
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = CactusColor.noteBackground
        container.clipsToBounds = true
        container.layer.cornerRadius = 10
        
        self.view.addSubview(container)
        
        container.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
        container.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20).isActive = true
        container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 10
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
        stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20).isActive = true
        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
                                
        let titleLabel = UILabel()
        self.noReflectionTextTitleLabel = titleLabel
        titleLabel.font = CactusFont.bold(18)
        titleLabel.textColor = CactusColor.royal
        titleLabel.text = (self.appSettings?.insights?.insightsTitle ?? "Today's Insight").uppercased()
        titleLabel.textAlignment = .center
        
        stack.addArrangedSubview(titleLabel)
        
        let messageLabel = UILabel()
        self.noReflectionTextLabel = messageLabel
        messageLabel.font = CactusFont.normal
        messageLabel.textColor = CactusColor.textDefault
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = appSettings?.insights?.noTextTodayMessage ?? "You didn't write anything today. That's fine, but Today's Insight only works when you capture your thoughts."
        stack.addArrangedSubview(messageLabel)
                
        let cta = FancyLinkButton()
        self.noReflectionLearnMoreButton = cta
        cta.textColorNormal = CactusColor.darkText
        cta.setTitle( appSettings?.insights?.learnMoreButtonText ?? "What are insights?", for: .normal)
        cta.tintColor = CactusColor.green
        cta.borderColor = CactusColor.green
        cta.addTarget(self, action: #selector(self.upgradeTapped(_:)), for: .primaryActionTriggered)
        stack.addArrangedSubview(cta)
    }
    
    func createUpgradeModal() {
        let container = UIView(frame: CGRect(0, 0, 100, 100))
        
        self.modalContainer = container
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = CactusColor.dolphin
        container.clipsToBounds = true
        container.layer.cornerRadius = 10
        
        self.view.addSubview(container)
        
        container.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20).isActive = true
        container.trailingAnchor.constraint(lessThanOrEqualTo: self.view.trailingAnchor, constant: -20).isActive = true
        container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 10
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
        stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20).isActive = true
        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.font = CactusFont.normal(16)
        titleLabel.textColor = CactusColor.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = (self.appSettings?.insights?.insightsTitle ?? "Today's Insight").uppercased()
        self.unlockTitleLabel = titleLabel
        stack.addArrangedSubview(titleLabel)
    
        let messageLabel = UILabel()
        messageLabel.font = CactusFont.normal
        messageLabel.textColor = CactusColor.white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.unlockMessageLabel = messageLabel
        messageLabel.text = self.appSettings?.insights?.revealInsightMessage ?? "Want to see Today's Insight?"
        stack.addArrangedSubview(messageLabel)
        
        let unlockbutton = PrimaryButton()
        self.unlockButton = unlockbutton
        let buttonText = self.appSettings?.insights?.revealInsightButtonText ?? "Show Me!"
        unlockButton?.addTarget(self, action: #selector(self.unlockInsights(_:)), for: .primaryActionTriggered)
        unlockbutton.setTitle(buttonText, for: .normal)
        stack.addArrangedSubview(unlockbutton)
        
        let upgradeButton = FancyLinkButton()
        upgradeButton.borderColor = CactusColor.green
        upgradeButton.textColorNormal = CactusColor.darkestGreen
        upgradeButton.tintColor = CactusColor.darkestGreen
        let upgradeButtonText = self.appSettings?.insights?.learnMoreButtonText ?? "What are insights?"
        upgradeButton.setTitle(upgradeButtonText, for: .normal)
        upgradeButton.addTarget(self, action: #selector(self.upgradeTapped(_:)), for: .primaryActionTriggered)
        self.learnMoreButton = upgradeButton
        
        stack.addArrangedSubview(upgradeButton)
        
    }
    
    func showModal(_ show: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.modalContainer?.alpha = show ? 1 : 0
        })
    }
    
    @objc func upgradeTapped(_ sender: Any?) {
        logger.info("Upgrade tapped")
        guard let pricingVc = ScreenID.Pricing.getViewController() as? PricingViewController else {
            return
        }
        self.pricingVc = pricingVc
        self.insightsWebView.sendShowMeAnalyticsEvent()
        pricingVc.modalPresentationStyle = .overCurrentContext
        self.present(pricingVc, animated: true, completion: nil)
    }
    
    @objc func unlockInsights(_ sender: Any?) {
        self.showModal(false)

        if !isBlank(self.reflectionResponse?.content.text) {
            self.insightsWebView.unlockInsights()
            self.insightsWebView.view.isHidden = false
            self.noInsightView?.isHidden = true
        } else {
            self.createNoInsightView()
            self.noInsightView?.isHidden = false
//            self.insightsWebView.view.isHidden = true
        }
    }
        
}
