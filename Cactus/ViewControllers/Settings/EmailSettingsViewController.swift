//
//  EmailSettingsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class EmailSettingsViewController: UIViewController {

    @IBOutlet weak var emailTextView: UITextView!
    
    @IBOutlet weak var saveActionsStackView: UIStackView!
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var firstNameInput: CactusTextInputField!
    @IBOutlet weak var lastNameInput: CactusTextInputField!
        
    @IBOutlet weak var cancelButton: TertiaryButton!
    
    var member: CactusMember?
    var memberUnsubscriber: Unsubscriber?
    var hasChanges: Bool {return FormatUtils.hasChanges(self.firstNameInput.text, self.member?.firstName) || FormatUtils.hasChanges(self.lastNameInput.text, self.member?.lastName)}
    var logger = Logger(fileName: "EmailSettingsViewController")
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
                
        self.emailTextView.textContainerInset = UIEdgeInsets.zero
        self.emailTextView.textContainer.lineFragmentPadding = 0
        
        self.view.setupKeyboardDismissRecognizer()
    }
        
    deinit {
        self.memberUnsubscriber?()
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
        } else {
            self.emailTextView.text = "(none provided)"
            self.firstNameInput.text = nil
            self.lastNameInput.text = nil
        }
    }

    func setupSaveActions() {
        self.logger.debug("Setting up save actions")
        if self.hasChanges {
            self.saveActionsStackView.isHidden = false
        } else {
            self.saveActionsStackView.isHidden = true
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.configureViews()
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
        
        CactusMemberService.sharedInstance.save(member) {_, error in
            if let error = error {
                self.logger.error("Failed to save cactus member", error)
            }
            self.saveButton.setEnabled(true)
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
}


extension EmailSettingsViewController: UITextFieldDelegate {
//    textFieldDidchange
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
