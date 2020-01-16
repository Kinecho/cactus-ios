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

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var addContactsButton: PrimaryButton!
    @IBOutlet weak var tableViewContainerView: UIView!
    
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    var tableViewController: ContactsTableViewController!
    let logger = Logger("SendFriendInviteViewController")
    var selectedContacts: [NativeContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }
    
    func configureViews() {
        self.messageTextView.layer.borderColor = CactusColor.borderLight.cgColor
        self.messageTextView.layer.borderWidth = 1
        self.messageTextView.layer.cornerRadius = 6
    }
    
    @IBAction func addContactsTapped(_ sender: Any) {
        self.selectedContacts = []
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
                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = self

                contactPicker.predicateForEnablingContact = NSPredicate(
                    format: "emailAddresses.@count > 0")
                self.present(contactPicker, animated: true, completion: nil)
            }
        }
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contacts: [CNContact]) {
        
        self.logger.info("Selected contact")
        self.handleContactsSelected(contacts: contacts)
    }
    
//    func contactPicker(_ picker: CNContactPickerViewController,
//                       didSelect contact: CNContact) {
//
//        self.logger.info("Selected contact")
//        let contacts = [contact]
//        self.handleContactsSelected(contacts: contacts)
//    }
    
    func handleContactsSelected(contacts: [CNContact]) {
        self.selectedContacts = contacts.map { (contact) in
            
            self.logger.info("\(contact.givenName) \(contact.familyName) - \(contact.emailAddresses.first?.value ?? "no emails")")
            
            var c = NativeContact()
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

}

extension SendFriendInviteViewController: ContactsTableViewControllerDelegate {
    func tableViewHeightChanged(updatedHeight: CGFloat) {
        self.tableViewHeightContraint.constant = updatedHeight
//        self.constrain
        self.view.setNeedsUpdateConstraints()
        self.tableViewContainerView.setNeedsUpdateConstraints()
    }
}
