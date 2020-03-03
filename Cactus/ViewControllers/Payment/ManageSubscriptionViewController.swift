//
//  ManageSubscriptionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
class ManageSubscriptionViewController: UIViewController {

    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var learnMoreButton: PrimaryButton!
    @IBOutlet weak var trialEndLabel: UILabel!
    @IBOutlet weak var upgradeDescriptionLabel: UILabel!
    @IBOutlet weak var upgradeStackView: UIStackView!
    @IBOutlet weak var invoiceStackView: UIStackView!
    @IBOutlet weak var nextInvoiceDescriptionLabel: UILabel!
    @IBOutlet weak var paymentStackView: UIStackView!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var changeBillingButton: UIButton!
    
    let logger = Logger("ManageSubscriptionViewContrller")
    var subscriptionDetails: SubscriptionDetails? {
        didSet {
            DispatchQueue.main.async {
                self.configureUpcomingInvoice()
            }
        }
    }
    
    var isAuthorizedForPayments: Bool {
        return false
    }
    
    var memberObserver: Unsubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.invoiceStackView.isHidden = true
        self.paymentStackView.addBackground(color: CactusColor.lightest, cornerRadius: 6)
        self.memberObserver = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, _) in
            if let error = error {
                self.logger.error("Failed to fetch cactus member", error)
                return
            }
            SubscriptionService.sharedInstance.getSubscriptionDetails { (details, error) in
                if let error = error {
                    self.logger.error("Failed to fetch subscription details", error)
                    self.subscriptionDetails = nil
                } else {
                    self.subscriptionDetails = details
                }
            }
            self.setupCurrentMembership(member: member)
        }
    }
    
    @IBAction func changeBillingTapped(_ sender: Any) {
        //no op yet
    }
    
    func configureUpcomingInvoice() {
        guard let invoice = self.subscriptionDetails?.upcomingInvoice else {
            self.invoiceStackView.isHidden = true
            return
        }
        
        var dateString: String?
        if let dateSeconds = invoice.nextPaymentDate_epoch_seconds {
            let nextDate = Date(timeIntervalSince1970: TimeInterval(dateSeconds))
            dateString = FormatUtils.formatDate(nextDate, currentYearFormat: "MMM d, yyyy")
        }
        let formattedPrice = formatPriceCents(invoice.amountCentsUsd, truncateWholeDollar: true) ?? "$0.00"
        var description = "Your next bill is for **\(formattedPrice)**"
        if let nextDueDate = dateString {
            description += " on **\(nextDueDate)**"
        }
        
        self.nextInvoiceDescriptionLabel.attributedText = MarkdownUtil.toMarkdown(description)
        
        var paymentString = ""
        if let card = invoice.defaultPaymentMethod?.card {
            self.paymentStackView.isHidden = false
            paymentString += card.brand?.displayName ?? ""
            if let last4 = card.last4 {
                paymentString += " ending in \(card.last4 ?? "")"
            }
            self.paymentMethodLabel.text = paymentString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            self.paymentStackView.isHidden = true
        }
        
        self.invoiceStackView.isHidden = false
    }
    
    func setupCurrentMembership(member: CactusMember?) {
        guard let member = member else {
            self.logger.info("No member, removing sub info")
            return
        }

        self.learnMoreButton.isHidden = member.subscription?.isActivated ?? false
        self.currentStatusLabel.text = member.subscription?.tier.displayName
        self.trialEndLabel.isHidden = !(member.subscription?.isInTrial ?? false)
        let daysLeft = member.subscription?.trialDaysLeft ?? 0
        if daysLeft <= 1 {
            self.trialEndLabel.text = "Trial ends today"
        } else {
            self.trialEndLabel.text = "\(daysLeft) days left in trial"
        }
        
        if member.subscription?.isActivated ?? false {
            self.upgradeStackView.isHidden = true
        } else {
            self.upgradeStackView.isHidden = false
            self.upgradeDescriptionLabel.text = (member.subscription?.isInTrial ?? false)
                ? SubscriptionService.sharedInstance.upgradeTrialDescription
                : SubscriptionService.sharedInstance.upgradeBasicDescription
        }
    }
}
