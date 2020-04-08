//
//  EmailSettingsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {
    
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var memberIdTextView: BorderedTextView!
    
    @IBOutlet weak var saveActionsStackView: UIStackView!
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var firstNameInput: CactusTextInputField!
    @IBOutlet weak var lastNameInput: CactusTextInputField!
    
    @IBOutlet weak var cancelButton: TertiaryButton!
    @IBOutlet weak var saveActionsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var deleteCactusButton: UIButton!
    
    var member: CactusMember?
    var memberUnsubscriber: Unsubscriber?
    var hasChanges: Bool {
        return FormatUtils.hasChanges(self.firstNameInput.text, self.member?.firstName) || FormatUtils.hasChanges(self.lastNameInput.text, self.member?.lastName)
        
    }
    
    let logger = Logger(fileName: "EmailSettingsViewController")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.member = CactusMemberService.sharedInstance.currentMember
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, _) in
            if let error = error {
                self.logger.error("Something went wrong fetching the current member using an observer", error)
            }
            
            self.member = member
            self.configureViews()
        })
        
        self.configureViews()
        self.firstNameInput.delegate = self
        self.lastNameInput.delegate = self
        
        self.firstNameInput.addTarget(self, action: #selector(self.setupSaveActions(_:)), for: .editingChanged)
        self.lastNameInput.addTarget(self, action: #selector(self.setupSaveActions(_:)), for: .editingChanged)
        
        self.emailTextView.textContainerInset = UIEdgeInsets.zero
        self.emailTextView.textContainer.lineFragmentPadding = 0
        
        self.memberIdTextView.textContainerInset = UIEdgeInsets.zero
        self.memberIdTextView.textContainer.lineFragmentPadding = 0
        
        self.saveButton.disabledBackgroundColor = CactusColor.lightGray.withAlphaComponent(0.4)
        self.cancelButton.disabledBackgroundColor = CactusColor.lightGray.withAlphaComponent(0.4)
        
        self.scrollContentView.setupKeyboardDismissRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        self.memberUnsubscriber?()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            self.saveActionsBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureViews()
    }
    
    func configureViews() {
        self.configureInputViews()
        self.setupSaveActions()
    }
    
    func configureInputViews() {
        if let member = self.member {
            self.emailTextView.text = member.email
            self.firstNameInput.text = member.firstName
            self.lastNameInput.text = member.lastName
            self.memberIdTextView.text = member.id
        } else {
            self.emailTextView.text = "(none provided)"
            self.firstNameInput.text = nil
            self.lastNameInput.text = nil
            self.memberIdTextView.text = nil
        }
    }
    
    @objc func setupSaveActions(_ sender: Any?=nil) {
        self.saveActionsStackView.isHidden = false
        if self.hasChanges {
            self.saveButton.setEnabled(true)
            self.cancelButton.setEnabled(true)
        } else {
            self.saveButton.setEnabled(false)
            self.cancelButton.setEnabled(false)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.configureViews()
        self.view.dismissKeyboard()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let member = self.member else {
            return
        }
        member.firstName = self.firstNameInput.text
        member.lastName = self.lastNameInput.text
        
        self.cancelButton.setEnabled(false)
        self.saveButton.setTitle("Saving...", for: .disabled)
        self.saveButton.setEnabled(false)
        self.view.dismissKeyboard()
        CactusMemberService.sharedInstance.save(member) {_, error in
            if let error = error {
                self.logger.error("Failed to save cactus member", error)
            }
            self.saveButton.setEnabled(true)
            self.saveButton.setTitle("Save", for: .disabled)
            self.cancelButton.setEnabled(true)
        }
    }
    
    @IBAction func firstNameChanged(_ sender: Any) {
        self.logger.info("Fist name changed")
        self.setupSaveActions()
    }
    
    @IBAction func lastNameChanged(_ sender: Any) {
        self.logger.info("Last name changed")
        self.setupSaveActions()
    }
    
    @IBAction func firstNameEditingEnded(_ sender: Any) {
        self.setupSaveActions()
    }
    
    @IBAction func lastNameEditingEnded(_ sender: Any) {
        self.setupSaveActions()
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
        ///verified
        var alertMessage = "This action is irreversible and will remove all of your Cactus data, including your journal entries."
        
        let alert = UIAlertController(title: "Delete Account", message: alertMessage, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender as? UIView
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if self.member?.tier.isPaidTier == true && self.member?.subscription?.billingPlatform == .APPLE && self.member?.subscription?.hasUpcomingCancellation == false {
            if self.member?.subscription?.isOptOutTrial == true {
                ///verfied
                alertMessage += "\n\nYou are currently in a free trial of Cactus Plus which is managed through Apple. "
                    + "To cancel your trial, visit Settings > Apple ID > Subscriptions on your phone or tablet."
            } else {
                ///verified
                alertMessage += "\n\nYour Cactus Plus subscription billing is managed through Apple. To cancel, visit Settings > Apple ID > Subscriptions on your phone or tablet."
            }
            
            alert.addAction(UIAlertAction(title: "Manage Subscription", style: .default, handler: { (_) in
                DispatchQueue.main.async {
                    let vc = ScreenID.ManageSubscription.getViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }))
        } else if self.member?.tier.isPaidTier == true && self.member?.subscription?.hasUpcomingCancellation == false {
            if self.member?.subscription?.isOptOutTrial == true {
                ///verified
                alertMessage += "\n\nYour trial of Cactus Plus will be automatically canceled and you will not be billed in the future."
            } else {
                ///verified
                alertMessage += "\n\nYour Cactus Plus subscription will be automatically canceled and you will not be billed in the future."
            }
        } else if self.member?.tier.isPaidTier == true && self.member?.subscription?.hasUpcomingCancellation == true {
            alertMessage += "\n\nYour subscription to Cactus Plus has already been canceled and you will not be billed in the future."
        }
        
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { (_) in
            AppMainViewController.shared.deleteAccount()
        }))
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let messageText = NSAttributedString(
            string: alertMessage,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                //NSAttributedString.Key.foregroundColor: UIColor.d,
                NSAttributedString.Key.font: CactusFont.normal(14)
            ]
        )

        alert.setValue(messageText, forKey: "attributedMessage")
        
//        alert.message = alertMessage
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileSettingsViewController: UITextFieldDelegate {
    //    textFieldDidchange
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
