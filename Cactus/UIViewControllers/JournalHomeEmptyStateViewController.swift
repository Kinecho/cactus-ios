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
    let logger = Logger("JournalHomeEmptyStateViewController")
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
                self.logger.error("JournalHomeEmptyStateViewController: Failed to get app settings", error)
                return
            }
            guard let promptContentEntryId = settings?.firstPromptContentEntryId else {
                self.logger.error("Could not find first promptId on the settings object")
                return
            }
            PromptContentService.sharedInstance.getByEntryId(id: promptContentEntryId) { (promptContent, error) in
                if let error = error {
                    self.logger.error("Failed to get prompt content", error)
                }
                self.promptContent = promptContent
                guard let promptId = promptContent?.promptId else {
                    return
                }
                self.responseListener = ReflectionResponseService.sharedInstance.observeForPromptId(id: promptId, { (responses, error) in
                    if let error = error {
                        self.logger.error("Error loading reflection responses on EmptyState", error)
                    }
                    self.reflectionResponses = responses
                })
            }
        }
    }
    
    deinit {
        self.responseListener?.remove()
    }
    
    @IBAction func beginTapped(_ sender: Any) {
        self.logger.info("let's begin was tapped")
        self.logger.info("navigating to \(self.promptContent?.entryId ?? "none found")")
        
        guard let promptContent = self.promptContent else {return}
        guard let vc = ScreenID.promptContentPageView.getViewController() as? PromptContentPageViewController else {return}
        vc.promptContent = promptContent
        vc.reflectionResponse = self.reflectionResponses?.first
        self.promptContentVC = vc
        vc.modalPresentationStyle = .fullScreen //this is needed to trigger the viewDidApper on the journal home
        vc.modalTransitionStyle = .crossDissolve
        
        CactusAnalytics.shared.startFirstPrompt()
        
        AppMainViewController.shared.present(vc, animated: true, completion: nil)
    }
}
