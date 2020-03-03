//
//  PricingViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import MessageUI

class PricingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var planStackView: UIStackView!
    @IBOutlet weak var footerStackView: UIStackView!
    
    @IBOutlet weak var footerDescriptionLabel: UILabel!
    @IBOutlet weak var footerIcon: UIImageView!
    @IBOutlet weak var continueButton: PrimaryButton!
    @IBOutlet weak var planContainerView: UIView!
    @IBOutlet weak var continueStackView: UIStackView!
    @IBOutlet weak var questionsTextView: UITextView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
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
    
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.closeButton.isHidden = !self.showCloseButton
        //Note: we are not showing products at the moment
        // self.loadSubscriptionProducts()
        
        self.configureQuestionsView()
        self.setupHeaderBackground()
    }
    
    func setupHeaderBackground() {
        let imageView = UIImageView(image: CactusImage.plusBg.getImage())
        imageView.contentMode = .scaleToFill
        self.mainStackView.insertSubview(imageView, at: 0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.headerStackView.topAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.headerStackView.leadingAnchor, constant: -100).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.headerStackView.trailingAnchor, constant: 100).isActive = true
    }
    
    func configureQuestionsView() {
        self.questionsTextView.delegate = self
        self.questionsTextView.attributedText = MarkdownUtil.centeredMarkdown("Questions? Email us at [help@cactus.app](mailto:help@cactus.app).")
        self.questionsTextView.tintColor = CactusColor.darkGreen
    }
    
    func loadSubscriptionProducts() {
        SubscriptionService.sharedInstance.getSubscriptionProductGroupEntryMap { (entryMap) in
            self.productGroupEntryMap = entryMap
        }
    }
    
    func configureProductsView() {
        guard let groupEntry = self.productGroupEntryMap?[SubscriptionTier.PLUS] else {
            self.planStackView.arrangedSubviews.forEach { (planView) in
                self.planStackView.removeArrangedSubview(planView)
            }
            return
        }
        self.planContainerView.isHidden = false
        self.continueStackView.isHidden = false
        if let footer = groupEntry.productGroup?.footer {
            self.footerDescriptionLabel.attributedText = MarkdownUtil.toMarkdown(footer.textMarkdown)?.withColor(CactusColor.white)
            self.footerIcon.image = footer.icon?.image
            self.footerIcon.isHidden = footer.icon?.image == nil
            self.footerStackView.isHidden = false
        } else {
            self.footerStackView.isHidden = true
        }
        
        groupEntry.products.forEach { (product) in
            let planView = SubscriptionPlanOptionView()
            planView.subscriptionProduct = product
            self.configurePlanTapGesture(planView: planView)
            if product.billingPeriod == groupEntry.defaultSelectedPeriod {
                planView.selected = true
            }
            self.planStackView.addArrangedSubview(planView)
        }
        
        self.planStackView.isHidden = false
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
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
}

extension PricingViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString.starts(with: "mailto:") {
            self.sendPricingEmail(textView)
        }
        return false
    }
}
