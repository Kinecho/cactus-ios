//
//  JournalHomeEmptyStateViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseFirestore
class JournalHomeEmptyStateViewController: UIViewController {
    @IBOutlet weak var letsBeginButton: PrimaryButton!
    
    var promptContent: PromptContent?
    var reflectionResponses: [ReflectionResponse]?
    var responseListener: ListenerRegistration?
    
    var promptContentVC: PromptContentPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchPromptContent()
    }
    
    func fetchPromptContent() {
        AppSettingsService.sharedInstance.getSettings { (settings, error) in
            if let error = error {
                print("JournalHomeEmptyStateViewController: Failed to get app settings", error)
                return
            }
            guard let promptContentEntryId = settings?.firstPromptContentEntryId else {
                print("Could not find first promptId on the settings object")
                return
            }
            PromptContentService.sharedInstance.getByEntryId(id: promptContentEntryId) { (promptContent, error) in
                if let error = error {
                    print("Failed to get prompt content", error)
                }
                self.promptContent = promptContent
                guard let promptId = promptContent?.promptId else {
                    return
                }
                self.responseListener = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
                    if let error = error {
                        print("Error loading reflection responses on EmptyState", error)
                    }
                    self.reflectionResponses = responses
                })
            }
        }
    }
    
    @IBAction func beginTapped(_ sender: Any) {
        print("let's begin was tapped")
        print("navigating to \(self.promptContent?.entryId ?? "none found")")
        
        guard let promptContent = self.promptContent else {return}
        guard let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.promptContentPageView) as? PromptContentPageViewController else {return}
        vc.promptContent = promptContent
        vc.reflectionResponse = self.reflectionResponses?.first
        self.promptContentVC = vc
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        AppDelegate.shared.rootViewController.present(vc, animated: true, completion: nil)
//        _ = AppDelegate.shared.rootViewController.showScreen(vc, wrapInNav: true)
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
