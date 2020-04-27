//
//  PricingViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseFirestore
class PricingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var planStackView: UIStackView!
    @IBOutlet weak var footerStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var footerDescriptionLabel: UILabel!
    @IBOutlet weak var footerIcon: UIImageView!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var planContainerView: UIView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var notAuthorizedForPaymentsLabel: UILabel!
    @IBOutlet weak var contactUsContainerView: UIView!

    @IBOutlet weak var pricingPageViewContainer: UIView!
    weak var pricingPageViewController: PricingFeaturePageViewController?
    
    var headerImageHeightConstraint: NSLayoutConstraint?
    var headerBackgroundImage: UIImageView?
    
    var isPurchasing: Bool = false {
        didSet {
            self.updatePurchasingState()
        }
    }
    var settingsUnsubscriber: ListenerRegistration?
    var appSettings: AppSettings?
    var showCloseButton = true
    let logger = Logger("PricingViewController")
    var productsLoaded = false
    var productGroupEntryMap: SubscriptionProductGroupEntryMap? {
        didSet {
            DispatchQueue.main.async {
                self.configureProductsView()
            }
        }
    }
    var selectedProductEntry: ProductEntry?
    
    var onDismiss: (() -> Void)?
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        StoreObserver.sharedInstance.delegate = self
        self.appSettings = AppSettingsService.sharedInstance.currentSettings
//        self.settingsUnsubscriber = AppSettingsService.sharedInstance.observeSettings({ (settings, error) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.logger.error("Failed to get app settings", error)
//                }
//                self.logger.info("got app settings")
//                self.appSettings = settings
////                self.configureFromSettings()
//            }
//        })
        
        self.closeButton.isHidden = !self.showCloseButton
//        self.planContainerView.isHidden = false
        self.setupHeaderBackground()
        self.titleLabel.text = "Get more with Cactus Plus"
        self.descriptionLabel.text = "Daily prompts, personalized insights, and more"
        self.configureFromSettings()
        self.loadSubscriptionProducts()
        CactusAnalytics.shared.pricingPageDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureFromSettings() {
        guard self.isViewLoaded else {
            return
        }
        self.updateAllCopy()
        self.layoutHeaderBackground()
    }
    
    func showNotAuthorizedForPayments(show: Bool) {
        self.logger.warn("User not authorized for payments")
        self.notAuthorizedForPaymentsLabel.isHidden = !show
    }
    
    deinit {
        self.settingsUnsubscriber?.remove()
        if StoreObserver.sharedInstance.delegate as? PricingViewController != nil {
           StoreObserver.sharedInstance.delegate = nil
        }
    }
    
    func setupHeaderBackground() {
        let height: CGFloat = self.appSettings?.pricingScreen?.headerBackgroundHeight ?? 260
        
        let imageView = UIImageView(image: CactusImage.plusBg.getImage())
        imageView.contentMode = .scaleToFill
        self.headerBackgroundImage = imageView
        self.mainStackView.insertSubview(imageView, at: 0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.headerStackView.topAnchor, constant: 0).isActive = true
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        self.headerImageHeightConstraint = heightConstraint
        imageView.leadingAnchor.constraint(equalTo: self.headerStackView.leadingAnchor, constant: -100).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.headerStackView.trailingAnchor, constant: 100).isActive = true
        self.layoutHeaderBackground()
    }
    
    func layoutHeaderBackground() {        
        let height: CGFloat = self.appSettings?.pricingScreen?.headerBackgroundHeight ?? 260
        self.headerImageHeightConstraint?.constant = height
        self.view.setNeedsLayout()
    }
    
    func loadSubscriptionProducts() {
        SubscriptionService.sharedInstance.getSubscriptionProductGroupEntryMap { (entryMap) in
            self.productGroupEntryMap = entryMap
        }
    }
    
    func updatePurchasingState() {
        if self.isPurchasing {
            self.continueButton.setTitle("Processing...", for: .disabled)
            self.continueButton.setEnabled(false)
        } else {
            self.continueButton.setEnabled(true)
        }
    }
    
    func updateAllCopy() {
        DispatchQueue.main.async {
            let settings = self.appSettings?.pricingScreen
            let pageTitle = settings?.pageTitleMarkdown ?? "Get more with Cactus Plus"
            self.titleLabel.attributedText = MarkdownUtil.centeredMarkdown(pageTitle, font: CactusFont.bold(26), color: CactusColor.white, boldColor: CactusColor.white)?.preventOrphanedWords()
            
            let pageDescription = settings?.pageDescriptionMarkdown ?? "Daily prompts, personalized insights, and more"
            self.descriptionLabel.attributedText = MarkdownUtil.centeredMarkdown(pageDescription, font: CactusFont.normal(18), color: CactusColor.white)?.preventOrphanedWords()
            
            self.updateFeatures()
            
            let continueText = isBlank(settings?.purchaseButtonText) ? "Try Cactus Plus" : settings?.purchaseButtonText
            self.continueButton.setTitle(continueText, for: .normal)
        }
    }
    
    func updateFeatures() {
        self.configurePricingPageViewController()
    }
    
    func configureProductsView() {
        self.planStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let groupEntry = self.productGroupEntryMap?[SubscriptionTier.PLUS] else {
            self.planStackView.arrangedSubviews.forEach { (planView) in
                self.planStackView.removeArrangedSubview(planView)
            }
            return
        }
        self.planContainerView.isHidden = false
        
        groupEntry.products.forEach { (productEntry) in
            let planView = SubscriptionPlanOptionView()

            planView.productEntry = productEntry
            self.configurePlanTapGesture(planView: planView)
            if productEntry.subscriptionProduct.billingPeriod == groupEntry.defaultSelectedPeriod {
                planView.selected = true
                self.selectedProductEntry = productEntry
            }
            self.planStackView.addArrangedSubview(planView)
        }

        if let footer = groupEntry.productGroup?.footer {
            self.logger.info("footer \(footer.textMarkdown ?? "no footer text")")
            self.footerDescriptionLabel.attributedText = MarkdownUtil.toMarkdown(footer.textMarkdown)?.withColor(CactusColor.white)
            self.footerIcon.image = footer.icon?.image
            self.footerStackView.isHidden = false
        } else {
            self.logger.info("No footer")
            self.footerStackView.isHidden = true
        }
        
    }
    
    func configurePlanTapGesture(planView: SubscriptionPlanOptionView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.planSelected(sender:)))
        planView.addGestureRecognizer(tapGesture)
    }
    
    @objc func planSelected(sender: UITapGestureRecognizer) {
        guard let planView = sender.view as? SubscriptionPlanOptionView else {
            return
        }
        self.logger.info("Plan selected \(planView.titleLabel.text ?? "unknown")")
        
        self.planStackView.subviews.forEach { (pv) in
            guard let p = pv as? SubscriptionPlanOptionView else {
                return
            }
            p.selected = false
        }
        
        planView.selected = true
        self.selectedProductEntry = planView.productEntry
        if let subscriptionProduct = planView.productEntry?.subscriptionProduct {
            CactusAnalytics.shared.selectedPlan(subscriptionProduct: subscriptionProduct)
        }
    }
    
    func configurePricingPageViewController() {
        let features = self.appSettings?.pricingScreen?.features ?? DEFAULT_PRICING_FEATURES
        self.pricingPageViewController?.features = features
        self.pricingPageViewContainer.isHidden = false
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        guard let entry = self.selectedProductEntry, let appleProduct = entry.appleProduct else {
            self.showError("No product was selected")
            return
        }
        
        self.logger.info("checking out with apple product id \(appleProduct.productIdentifier)")
        self.isPurchasing = true
        SubscriptionService.sharedInstance.submitPurchase(product: appleProduct)
        CactusAnalytics.shared.checkoutContinueTapped(subscriptionProduct: entry.subscriptionProduct)
        
    }
 
    func showError(_ message: String) {
        //todo: not implemented
        self.logger.error("Failded to check out. \(message)")
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.onDismiss?()
        })
    }
    
    func sendPricingEmail(_ sender: Any) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText = "\(appVersion ?? "") (\(buildVersion ?? "1"))"
        let systemVersion = UIDevice.current.systemVersion
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["help@cactus.app"])
            mail.setSubject("Cactus Plus - App version \(versionText) on iOS \(systemVersion)")
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Unable to open email client", message: "Please send us an email to help@cactus.app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Copy Email Address", style: .default, handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = "help@cactus.app"
            }))
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func restoreTapped(_ sender: Any) {
        SubscriptionService.sharedInstance.restorePurchase()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PricingFeaturePageViewController {
            self.pricingPageViewController = vc
            self.configurePricingPageViewController()
        }
    }
}

extension PricingViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString.starts(with: "mailto:") {
            self.sendPricingEmail(textView)
        }
        return false
    }
}

extension PricingViewController: StoreObserverDelegate {
    func handlePurchseCompleted(verifyReceiptResult: CompletePurchaseResult?, error: Any?) {
        DispatchQueue.main.async {
            self.logger.info("Handling purchase completed")
            self.isPurchasing = false
            
            CactusAnalytics.shared.purchaseCompleted(productEntry: self.selectedProductEntry)
            if verifyReceiptResult?.success == true {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
