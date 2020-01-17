//
//  SendFriendInviteViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 1/16/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import ContactsUI

class SendFriendInviteViewController: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var emptyStateContainerView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var chooseContactsButton: PrimaryButton!
    @IBOutlet weak var tableViewContainerView: UIView!
    @IBOutlet weak var contactsViewContainer: UIView!
    
    @IBOutlet weak var editTableButton: UIButton!
    @IBOutlet weak var selectedContactsLabel: UILabel!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var inviteButton: PrimaryButton!
    @IBOutlet weak var addContactsButton: SecondaryButton!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    var contactPickerController: CNContactPickerViewController!
    var tableViewController: ContactsTableViewController!
    let logger = Logger("SendFriendInviteViewController")
    var selectedContacts: [SocialContact] = []
    var messageBottomConstraintConstantInitial: CGFloat = 20.0
    var messageBottomConstraintConstant: CGFloat = 0.0
    var messageViewBottomOffset: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.addKeyboardNotification()
        self.messageBottomConstraintConstant = self.textViewBottomConstraint.constant
        self.messageBottomConstraintConstantInitial = self.textViewBottomConstraint.constant
    }
    
    deinit {
        self.removeKeyboardNotification()
        self.presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    fileprivate func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureViews() {
        self.messageStackView.addBackground(color: CactusColor.promptBackground, cornerRadius: nil)
        self.messageTextView.layer.borderColor = CactusColor.secondaryBorder.cgColor
        self.messageTextView.layer.borderWidth = 1
        self.messageTextView.layer.cornerRadius = 12
        self.messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 6, right: 4)
        self.tableViewHeightContraint.constant = 0
        self.configureActionButtons()
        self.view.setupKeyboardDismissRecognizer()
        
        let toolbar = UIToolbar(frame: CGRect(0, 0, 100, 100))
        toolbar.barStyle = .default
        toolbar.isUserInteractionEnabled = true
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        let toolbarItems = [flexSpace, doneButton]
        toolbar.setItems(toolbarItems, animated: false)
        toolbar.sizeToFit()
//        toolbar.
        self.messageTextView.inputAccessoryView = toolbar
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(
            format: "emailAddresses.@count > 0")
        self.contactPickerController = contactPicker
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.contactPickerController.
    }
    
    @objc func dismissKeyboard() {
        self.view.dismissKeyboard()
    }
    
    func configureActionButtons() {   
        if self.tableViewController.contacts.isEmpty {
            self.emptyStateContainerView.isHidden = false
            self.contactsViewContainer.isHidden = true
            self.inviteButton.setEnabled(false)
            self.inviteButton.isHidden = true
            self.chooseContactsButton.isHidden = false
            self.addContactsButton.isHidden = true
            self.messageStackView.isHidden = true
            self.selectedContactsLabel.isHidden = true
        } else {
            self.emptyStateContainerView.isHidden = true
            self.contactsViewContainer.isHidden = false
            self.inviteButton.setEnabled(true)
            self.inviteButton.isHidden = false
            self.chooseContactsButton.isHidden = true
            self.addContactsButton.isHidden = false
            self.messageStackView.isHidden = false
            self.selectedContactsLabel.isHidden = false
            self.selectedContactsLabel.text = "Send Invites (\(tableViewController.contacts.count))"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.messageViewBottomOffset = self.view.frame.maxY - self.messageStackView.frame.maxY
    }
    
    @IBAction func inviteTapped(_ sender: Any) {
        self.logger.info("Send Invites NOT IMPLEMENTED YET")
        
    }
    
    @IBAction func addContactsTapped(_ sender: Any) {
        self.openContactsMenu()
    }
    @IBAction func chooseContactsTapped(_ sender: Any) {
        self.openContactsMenu()
    }
    
    func openContactsMenu() {
        self.selectedContacts = []
        self.tableViewController.isEditing = false
        self.configureEditTableButton()
        CNContactStore().requestAccess(for: .contacts) { (access, error) in
            print("Access: \(access)")
            guard error == nil else {
                self.logger.error("Error getting contact permission", error)
                return
            }
            guard access else {
                self.logger.info("Not getting contacts - permission not granted")
                return
            }
            
            DispatchQueue.main.async {
                self.present(self.contactPickerController, animated: true, completion: nil)
            }
        }
    }
    
    ///Select multiple contacts. Implement this method to use muti select. Note: search bar will not be available
    //    func contactPicker(_ picker: CNContactPickerViewController,
    //                       didSelect contacts: [CNContact]) {
    //
    //        self.logger.info("Selected \(contacts.count) contacts")
    //        self.handleContactsSelected(contacts: contacts)
    //    }

    ///Select a single contact. A search bar will be visible
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contact: CNContact) {
        
        self.logger.info("Selected single contact")
        self.handleContactsSelected(contacts: [contact])
    }
    
    func handleContactsSelected(contacts: [CNContact]) {
        self.selectedContacts = contacts.map { (contact) in
                        
            self.logger.info("\(contact.givenName) \(contact.familyName) - \(contact.emailAddresses.first?.value ?? "no emails")")
            
            var c = SocialContact()
            
            c.avatarImageData = contact.thumbnailImageData            
            c.email = contact.emailAddresses.first?.value as String?
            c.firstName = contact.givenName
            c.lastName = contact.familyName
            return c
        }
        if selectedContacts.isEmpty {
            self.handleNoContactsSelected()
        } else {
            self.handleContactsSelected()
        }
    }
    
    func handleNoContactsSelected() {
        //no action
    }
   
    func handleContactsSelected() {
        self.tableViewController.addContacts(self.selectedContacts)
        self.selectedContacts = []
    }
    
    @IBAction func editContactsTapped(_ sender: Any) {        
        self.tableViewController.isEditing.toggle()
        self.configureEditTableButton()
    }
    
    func configureEditTableButton() {
        let isEditing = self.tableViewController.isEditing
        if isEditing {
            self.editTableButton.setTitle("Done", for: .normal)
        } else {
            self.editTableButton.setTitle("Edit", for: .normal)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "embedSelectedContacts" else {
            return
        }
        
        guard let tableView = segue.destination as? ContactsTableViewController else {
            return
        }
        
        tableView.contacts = selectedContacts
        tableView.delegate = self
        self.tableViewController = tableView
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        var translateY: CGFloat = 0
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            self.messageBottomConstraintConstant <= self.messageBottomConstraintConstantInitial {
            translateY = keyboardFrame.height - self.messageViewBottomOffset
            self.logger.debug("Keybord Frame.height = \(keyboardFrame.height)")
            self.logger.debug("Translating keyboard by \(translateY)")
        }
        
//        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
//        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.05,
            options: .curveEaseOut,
            animations: {
                self.messageStackView.transform = CGAffineTransform(translationX: 0, y: -translateY)
            })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.messageStackView.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SendFriendInviteViewController: ContactsTableViewControllerDelegate {
    func tableViewHeightChanged(updatedHeight: CGFloat) {
        self.tableViewHeightContraint.constant = min(updatedHeight, 300)
        self.view.setNeedsUpdateConstraints()
        self.tableViewContainerView.setNeedsUpdateConstraints()
        self.configureActionButtons()
    }
}
