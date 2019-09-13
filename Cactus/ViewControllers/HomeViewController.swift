//
//  HomeViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class HomeViewController: UISplitViewController, UISplitViewControllerDelegate {

    @objc func logout(sender: Any) {
        print("Attempting to log out")
        AuthService.sharedInstance.logOut(self)
    }
    
    @objc func showAccountPage(sender: Any) {
        AppDelegate.shared.rootViewController.showScreen(ScreenID.memberProfile, wrapInNav: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let splitViewController = self
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
//        navigationItem.leftBarButtonItem = editButtonItem
        
        let showAccountItem = UIBarButtonItem(
            title: "Account",
            style: .plain,
            target: self,
            action: #selector(self.showAccountPage(sender:))
        )
        
        navigationItem.leftBarButtonItem = showAccountItem
//        navigationController.navigationItem.leftBarButtonItem = showAccountItem
        
        // Do any additional setup after loading the view.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? JournalEntryDetailViewController else { return false }
        if topAsDetailController.sentPrompt == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
