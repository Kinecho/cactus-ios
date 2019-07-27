//
//  MasterViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore
class MasterViewController: UITableViewController {

    var detailViewController: JournalEntryDetailViewController? = nil
    var sentPrompts = [SentPrompt]()

    var promptListener:ListenerRegistration?
    
    @objc func logout(sender: Any) {
        print("Attempting to log out")
        AuthService.sharedInstance.logOut(self)
    }
    
    
    @objc func showAccountPage(sender: Any){
        AppDelegate.shared.rootViewController.showScreen(ScreenID.MemberProfile, wrapInNav: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let showAccountItem = UIBarButtonItem(
            title: "Account",
            style: .plain,
            target: self,
            action:  #selector(self.showAccountPage(sender:))
        )
        
        navigationItem.leftBarButtonItem = showAccountItem
//        navigationController.navigationItem.leftBarButtonItem = showAccountItem
        
        guard let member = CactusMemberService.sharedInstance.getCurrentMember() else {
            print("No cactus member found")
            return
        }
        print("Got current cactus member \(member.email ?? "No Email found" ) - \(member.id ?? "not found")")
        
        self.promptListener = SentPromptService.sharedInstance.observeSentPrompts(member: member, { (prompts, error) in
            print("Got sent prompts \(prompts?.count ?? 0)")
            self.sentPrompts = prompts ?? []
            self.tableView.reloadData()
        })
    
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? JournalEntryDetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = sentPrompts[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! JournalEntryDetailViewController
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentPrompts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = sentPrompts[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row): \(object.promptId ?? "unknown")"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sentPrompts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

