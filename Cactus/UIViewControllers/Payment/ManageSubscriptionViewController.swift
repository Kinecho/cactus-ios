//
//  ManageSubscriptionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import StoreKit
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
    @IBOutlet weak var restoreButton: SecondaryButton!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var detailsContainerStackView: UIStackView!
    @IBOutlet weak var paymentMethodIcon: UIImageView!
    @IBOutlet weak var managePaymentButton: UIButton!
    
    let logger = Logger("ManageSubscriptionViewContrller")
    var subscriptionDetails: SubscriptionDetails? {
        didSet {
            DispatchQueue.main.async {
                self.configureUpcomingInvoice()
            }
        }
    }
    var member: CactusMember? {
        didSet {
            self.loadSubscriptionDetails()
        }
    }
    var isAuthorizedForPayments: Bool {
        return false
    }
    var detailsLoading = false {
        didSet {
            self.configureLoading()
        }
    }

    var isLoading: Bool {
        self.detailsLoading
    }
    
    var formattedPrice: String {
        if let applePrice = self.subscriptionDetails?.upcomingInvoice?.appleProductPrice?.localePriceFormatted {
            return applePrice
        }
        
        return formatPriceCents(self.subscriptionDetails?.upcomingInvoice?.amountCentsUsd, truncateWholeDollar: true) ?? "$0.00"
    }
    
    var upgradeCopy: UpgradeCopy? = AppSettingsService.sharedInstance.currentSettings?.upgradeCopy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managePaymentButton.isHidden = true
        self.invoiceStackView.isHidden = true
        self.paymentStackView.addBackground(color: CactusColor.paymentBackground, cornerRadius: 6)
      
        self.setupCurrentMembership(member: self.member)
        self.loadSubscriptionDetails()
        self.configureUpcomingInvoice()
    }
    
    func loadSubscriptionDetails() {
        guard !self.detailsLoading else {
            return
        }
        
        self.detailsLoading = true
        if self.member?.tier.isPaidTier == true {
            SubscriptionService.sharedInstance.getSubscriptionDetails { (details, error) in
                defer {
                    self.detailsLoading = false
                }
                if let error = error {
                    self.logger.error("Failed to fetch subscription details", error)
                    DispatchQueue.main.async {
                        self.subscriptionDetails = nil
                        
                        self.showError("Unable to load your subscription details. Please try again later.")
                    }
                } else {
                    self.subscriptionDetails = details
                }
            }
        } else {
            self.detailsLoading = false
        }
        self.setupCurrentMembership(member: member)
    }
    
    func showError(_ message: String) {
        guard self.isViewLoaded else {
            return
        }
        self.nextInvoiceDescriptionLabel.text = message
        self.nextInvoiceDescriptionLabel.isHidden = false
    }
    
    func configureLoading() {
        guard self.isViewLoaded else {
            return
        }
        DispatchQueue.main.async {
            self.detailsContainerStackView.isHidden = self.isLoading            
            self.loadingStackView.isHidden = !self.isLoading
        }
    }
    
    @IBAction func changeBillingTapped(_ sender: Any) {
        //no op yet
    }
    
    func getTrialString(invoice: SubscriptionInvoice, subscriptionProduct: SubscriptionProduct? = nil) -> String {
        var description: String = ""
        if invoice.isInOptOutTrial,
            let trialEndDate = invoice.optOutTrialEndsAt,
            let trialEndDateString = FormatUtils.formatDate(trialEndDate, currentYearFormat: "MMMM, d, yyyy") {
            let periodString = subscriptionProduct?.billingPeriod.isReoccurring == true ? "per  \(subscriptionProduct?.billingPeriod.displayName ?? "")" : ""
            description = "Your free trial ends on **\(trialEndDateString)** and you will be billed **\(formattedPrice)** \(periodString)".trimmingCharacters(in: .whitespacesAndNewlines) + "."
        }
        return description
    }
    
    func getActiveBillingString(invoice: SubscriptionInvoice, subscriptionProduct: SubscriptionProduct? = nil) -> String {
        let billingPeriod = subscriptionProduct?.billingPeriod
        var nextBillDateString: String?
        if let dateSeconds = invoice.nextPaymentDate_epoch_seconds {
            let nextDate = Date(timeIntervalSince1970: TimeInterval(dateSeconds))
            nextBillDateString = FormatUtils.formatDate(nextDate, currentYearFormat: "MMMM d, yyyy")
        }
        
        var description = invoice.isAutoRenew != false ? "Your next \(billingPeriod?.productTitle?.lowercased() ?? "") bill is for **\(formattedPrice)**" : "Your subscription will end"
        if let nextDueDate = nextBillDateString {
            description += " on **\(nextDueDate)**."
        }
        
        return description
    }
    
    func getSubscriptionEndedDescription(_ invoice: SubscriptionInvoice) -> String {
        if let endDate = invoice.periodEndAt, let dateString = FormatUtils.formatDate(endDate, currentYearFormat: "MMMM d, yyyy") {
            return "Your subscription ended on **\(dateString)**"
        }
        return "Your subscription has ended."

    }
    
    func getStatusDescriptioninvoice(invoice: SubscriptionInvoice, subscriptionProduct: SubscriptionProduct? = nil) -> String? {
        if invoice.isExpired == true || invoice.subscriptionStatus.isEnded {
            return getSubscriptionEndedDescription(invoice)
        }
                
        if invoice.isInOptOutTrial || invoice.subscriptionStatus == SubscriptionStatus.in_trial {
            return self.getTrialString(invoice: invoice, subscriptionProduct: subscriptionProduct)
        }
        
        if invoice.isAutoRenew == true || invoice.subscriptionStatus.isActive {
            return self.getActiveBillingString(invoice: invoice, subscriptionProduct: subscriptionProduct)
        }
        
        return nil
    }
    
    func configureUpcomingInvoice() {
        guard self.isViewLoaded else {
            return
        }
        guard self.member?.subscription?.isActivated == true,
            let invoice = self.subscriptionDetails?.upcomingInvoice else {
                self.invoiceStackView.isHidden = true
                return
        }
        let subscriptionProduct = self.subscriptionDetails?.subscriptionProduct
        let description = getStatusDescriptioninvoice(invoice: invoice, subscriptionProduct: subscriptionProduct)
        self.nextInvoiceDescriptionLabel.attributedText = MarkdownUtil.toMarkdown(description)
        self.updatePaymentInfo(invoice: invoice, subscriptionProduct: subscriptionProduct)
    }
    
    func updatePaymentInfo(invoice: SubscriptionInvoice, subscriptionProduct: SubscriptionProduct?) {
        var paymentString = ""
        if let card = invoice.defaultPaymentMethod?.card {
            self.paymentStackView.isHidden = false
            paymentString += card.brand?.displayName ?? ""
            if let last4 = card.last4 {
                paymentString += " ending in \(last4)"
            }
            self.paymentMethodLabel.text = paymentString.trimmingCharacters(in: .whitespacesAndNewlines)
            self.paymentMethodLabel.isHidden = false
            self.managePaymentButton.isHidden = true
            if let icon = CactusImage.creditCard.getImage() {
                self.paymentMethodIcon.setImage(icon)
                self.paymentMethodIcon.isHidden = false
                self.paymentMethodIcon.tintColor = CactusColor.green
            } else {
                self.paymentMethodIcon.isHidden = true
            }
        } else if invoice.billingPlatform == .APPLE {
            self.managePaymentButton.setTitle("Manage on the App Store", for: .normal)
            self.managePaymentButton.isHidden = false
            self.paymentMethodIcon.tintColor = CactusColor.blackInvertable
            self.paymentMethodLabel.isHidden = true
            if let icon = CactusImage.apple.getImage() {
                self.paymentMethodIcon.setImage(icon)
                self.paymentMethodIcon.isHidden = false
            } else {
                self.paymentMethodIcon.isHidden = true
            }
        } else if invoice.billingPlatform == .GOOGLE {
            self.managePaymentButton.setTitle("Manage on Google Play", for: .normal)
            self.managePaymentButton.isHidden = false
            self.paymentMethodLabel.isHidden = true
            if let icon = CactusImage.google.getImage() {
                self.paymentMethodIcon.setImage(icon)
                self.paymentMethodIcon.isHidden = false
            } else {
                self.paymentMethodIcon.isHidden = true
            }
        } else {
            self.paymentStackView.isHidden = true
        }
        
        self.invoiceStackView.isHidden = false
    }
    
    @IBAction func manageSubscriptionTapped(_ sender: Any) {
        guard let invoice = self.subscriptionDetails?.upcomingInvoice else {
            return
        }
        let platform = invoice.billingPlatform
        
        var url: URL?
        switch platform {
        case .APPLE:
            url = URL(string: "https://apps.apple.com/account/subscriptions")
        case .GOOGLE:
            let sku = invoice.androidProductId ?? ""
            let packageName = invoice.androidPackageName ?? ""
            
            url = URL(string: "https://play.google.com/store/account/subscriptions?sku=\(sku)&package=\(packageName)")
        default:
            logger.info("Unsupported platform")
        }
        if let url = url {
            NavigationService.shared.openUrl(url: url)
        }
        
    }
    
    func setupCurrentMembership(member: CactusMember?) {
        guard self.isViewLoaded else {
            return
        }
        guard let member = member else {
            self.logger.info("No member, removing sub info")
            return
        }
        
        self.learnMoreButton.isHidden = member.subscription?.isActivated ?? false
        self.learnMoreButton.setTitle(self.upgradeCopy?.manageSubscription.upgradeButtonText ?? "Upgrade", for: .normal)
        
        self.currentStatusLabel.text = member.subscription?.tier.displayName
        self.trialEndLabel.isHidden = !(member.subscription?.isInOptInTrial ?? false)
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
            self.upgradeDescriptionLabel.attributedText = (member.subscription?.isInOptInTrial ?? false)
                ? MarkdownUtil.toMarkdown(SubscriptionService.sharedInstance.upgradeTrialDescription)
                : MarkdownUtil.toMarkdown(SubscriptionService.sharedInstance.upgradeBasicDescription)
        }
    }
    @IBAction func restorePurchases(_ sender: Any) {
        SubscriptionService.sharedInstance.restorePurchase()
        
    }
}
