//
//  ContactsTableViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 1/16/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

protocol ContactsTableViewControllerDelegate: class {
    func tableViewHeightChanged(updatedHeight: CGFloat)
}

class ContactsTableViewController: UITableViewController {
    let logger = Logger("ContactsTableViewController")
    var contacts: [SocialContact] = [] {
        didSet {
            self.notifyHeightChanged()
        }
    }
    weak var delegate: ContactsTableViewControllerDelegate?
    let CELL_HEIGHT: CGFloat = 75
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension

        self.tableView.reloadData()
        self.notifyHeightChanged()
    }
    
    func addContacts(_ contacts: [SocialContact]) {
        contacts.forEach { (contact) in
            guard let email = contact.email else {
                return
            }
            let hasContact = self.contacts.contains(where: { (c) -> Bool in
                return c.email == email
            })
                        
            if !hasContact {
                self.contacts.append(contact)
            }
        }
        self.tableView.reloadData()
        self.notifyHeightChanged()
    }
    
    func reset() {
        self.contacts.removeAll()
        self.tableView.reloadData()
    }
    
    func notifyHeightChanged() {
        let calculatedHeight = self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom
        self.logger.info("Heigt using contentSize: \(calculatedHeight)")
        let contactHeight = CGFloat(self.contacts.count) * CELL_HEIGHT
        self.logger.info("Contat Height: \(contactHeight)")
        self.delegate?.tableViewHeightChanged(updatedHeight: contactHeight)
    }
    
    func getContact(at indexPath: IndexPath) -> SocialContact? {
        return contacts[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        guard let cell = c as? SocialContactTableViewCell else {
            return c
        }
        
        let contact = getContact(at: indexPath)
        cell.textLabel?.text = contact?.fullName ?? ""
        cell.detailTextLabel?.text = contact?.email ?? ""
                
        if let avatarImage = contact?.avatarImage {
            cell.imageView?.image = avatarImage
        } else {
            cell.imageView?.image = CactusImage.avatar1.getImage()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if self.contacts.isEmpty {
                self.isEditing = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
