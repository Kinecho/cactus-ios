//
//  UpgradeJournalFeedCollectionReusableView.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class UpgradeJournalFeedCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var upgradeButton: PrimaryButton!
    
    @IBInspectable var stackViewBackgroundColor: UIColor = CactusColor.magenta
    @IBInspectable var borderRadius: CGFloat = 0
    
    var appSettings: AppSettings? {
        didSet {
            if appSettings != nil {
                DispatchQueue.main.async {
                    self.setNeedsLayout()
                }
            }
        }
    }
    var member: CactusMember? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var addedBackground = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
//        self.titleLabel.font = CactusFont.bold(18)
//        self.descriptionLabel.font = CactusFont.normal(18)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateCopy()
    }
    
    func updateCopy() {
        let upgradeView = self
        guard let member = self.member, let settings = self.appSettings, let copy = settings.upgradeCopy?.journalHomeBanner else {
            self.isHidden = true
            return
        }
        
        let isActivated = member.subscription?.isActivated ?? false
        let inTrial = member.subscription?.isInOptInTrial ?? false
        let daysLeft = member.subscription?.trialDaysLeft
        if isActivated || member.tier.isPaidTier {
            upgradeView.isHidden = true
            return
        }
        
        if inTrial {
            if daysLeft == 1 {
                upgradeView.titleLabel.text = "Trial ends today"
            } else {
                upgradeView.titleLabel.text = "\(daysLeft ?? 0) days left in trial"
            }
            
            upgradeView.descriptionLabel.attributedText = MarkdownUtil.toMarkdown(SubscriptionService.sharedInstance.upgradeTrialDescription)
        } else {
            upgradeView.upgradeButton.setTitle(copy.basicTier.upgradeButtonText, for: .normal)
            upgradeView.titleLabel.text = copy.basicTier.title
            upgradeView.titleLabel.isHidden = isBlank(copy.basicTier.title)
            upgradeView.descriptionLabel.attributedText = MarkdownUtil.toMarkdown(copy.basicTier.descriptionMarkdown, color: CactusColor.white, boldColor: CactusColor.white )
        }
        
        upgradeView.titleLabel.isHidden = isBlank(titleLabel.text)
        self.isHidden = false
//        upgradeView.setNeedsLayout()
    }
    
}
