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
    var contacts: [NativeContact] = [] {
        didSet {
            self.notifyHeightChanged()
        }
    }
    var delegate: ContactsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension

        self.tableView.reloadData()
        self.notifyHeightChanged()
        // Do any additional setup after loading the view.
    }
    
    func addContacts(_ contacts: [NativeContact]) {
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
    
    func notifyHeightChanged() {
        let calculatedHeight = self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom
        self.logger.info("Heigt using contentSize: \(calculatedHeight)")
        let contactHeight = CGFloat(self.contacts.count * 56)
        self.logger.info("Contat Height: \(contactHeight)")
        self.delegate?.tableViewHeightChanged(updatedHeight: contactHeight)
    }
    
    func getContact(at indexPath: IndexPath) -> NativeContact? {
        return contacts[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") ?? UITableViewCell()
        let contact = getContact(at: indexPath)
        cell.textLabel?.text = contact?.fullName ?? ""
        cell.detailTextLabel?.text = contact?.email ?? ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
