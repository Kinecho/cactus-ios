//
//  InviteContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 1/15/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import ContactsUI
class InviteContentViewController: PromptContentViewController, CNContactPickerDelegate {

    @IBOutlet weak var invitePreview: SocialActivityCardView!
    @IBOutlet weak var inviteTitleLabel: UILabel!
    @IBOutlet weak var inviteDescriptionLabel: UILabel!
    @IBOutlet weak var inviteButton: PrimaryButton!
    let log = Logger("InviteConentViewController")
    var sendInviteViewController: SendFriendInviteViewController?
    var selectedContacts: [SocialContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendInviteViewController = ScreenID.inviteFriend.getViewController() as? SendFriendInviteViewController
        self.sendInviteViewController?.delegate = self
        self.configureView()
    }

    override func configureView() {
        guard self.isViewLoaded else {
            return
        }
        invitePreview.addShadows()
        self.inviteDescriptionLabel.text = self.inviteDescriptionLabel.text?.preventOrphanedWords()
    }
    
    @IBAction func inviteTapped(_ sender: Any) {
        self.showInviteScreen()
        
//        CNContactStore().requestAccess(for: .contacts) { (access, error) in
//          print("Access: \(access)")
//            guard error == nil else {
//                self.log.error("Error getting contact permission", error)
//                return
//            }
//            guard access else {
//                self.log.info("Not getting contacts - permission not granted")
//                return
//            }
//
//            DispatchQueue.main.async {
//                let contactPicker = CNContactPickerViewController()
//                contactPicker.delegate = self
//                contactPicker.predicateForEnablingContact = NSPredicate(
//                  format: "emailAddresses.@count > 0")
//                self.present(contactPicker, animated: true, completion: nil)
//            }
//        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contacts: [CNContact]) {
        
        self.log.info("Selected \(contacts.count) contacts")
        self.selectedContacts = contacts.map { (contact) in
            
            self.log.info("\(contact.givenName) \(contact.familyName) - \(contact.emailAddresses.first?.value ?? "no emails")")
            
            var c = SocialContact()
            c.email = contact.emailAddresses.first?.value as String?
            c.firstName = contact.givenName
            c.lastName = contact.familyName
            return c
        }
        if selectedContacts.isEmpty {
            self.handleNoContactsSelected()
        } else {
            self.showInviteScreen()
        }
    }
    
    func handleNoContactsSelected() {
        //no action
    }
    
    func showInviteScreen() {
        guard let vc = sendInviteViewController else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }
        
}

extension InviteContentViewController: SendFriendInviteViewControllerDelegate {
    func invitesSentSuccessfully() {
        self.delegate?.nextScreen()
    }
}
