//
//  LinkedAccountsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/9/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

import FirebaseFirestore
import FirebaseAuth
class LinkedAccountsTableViewController: UITableViewController {

    let reuseIdentifier = "accountCell"
    var userListener: AuthStateDidChangeListenerHandle?
    var currentUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.userListener = AuthService.sharedInstance.getAuthStateChangeHandler(completion: { (_, user) in
            self.currentUser = user
            self.tableView.reloadData()
        })
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUser?.reload(completion: { (error) in
            if let error = error {
                print("Error refreshing profile", error)
            }
            self.tableView.reloadData()
        })
    }
    
    deinit {
        AuthService.sharedInstance.removeAuthStateChangeListener(self.userListener)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentUser?.providerData.filter({ (_) -> Bool in
//            return info.providerID != "password"
            return true
        }).count ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let data = self.currentUser?.providerData[indexPath.row] else {
            cell.textLabel?.text = nil
            cell.imageView?.image = nil
            cell.detailTextLabel?.text = nil
            
            return cell
        }
        cell.textLabel?.text = self.getProviderDisplayName(data.providerID)
        if let image = CactusImage.fromProviderId(data.providerID) {
            cell.imageView?.setImage(image)
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    func getProviderDisplayName(_ providerId: String) -> String? {
        switch providerId {
        case "google.com":
            return "Google"
        case "twitter.com":
            return "Twitter"
        case "facebook.com":
            return "Facebook"
        case "password":
            return "Email/Password"
        case "apple.com":
            return "Apple"
        default:
            return nil
        }
    }
}
