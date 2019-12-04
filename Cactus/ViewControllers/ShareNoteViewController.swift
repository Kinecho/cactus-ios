//
//  ShareNoteViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/11/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ShareNoteViewController: UIViewController {
    
    @IBOutlet weak var shareSubTextView: UITextView!
    @IBOutlet weak var noteContainerView: UIView!
    @IBOutlet weak var shareLinkButton: PrimaryButton!
    @IBOutlet weak var shareButton: TertiaryButton!
    var logger = Logger(fileName: "ShareNoteViewController")
    var reflectionVc: SharedReflectionViewController?
    var promptContent: PromptContent!
    var reflectionResponse: ReflectionResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.embedSharedReflection()
        self.shareSubTextView.attributedText = MarkdownUtil.centeredMarkdown("Become more courageous and **build trust and connection** with others.",
                                                                             font: CactusFont.normal,
                                                                             color: CactusColor.lightGreen)
        self.configureSharing()
    }
    
    func embedSharedReflection() {
        if self.reflectionVc == nil {
            let vc =  SharedReflectionViewController.loadFromNib()
            self.reflectionVc = vc
            vc.willMove(toParent: self)
            self.addChild(vc)
        } else {
            logger.info("Reflection View already set up")
        }
        
        guard let vc = self.reflectionVc else {
            logger.warn("No reflectionVc found, can't continue")
            return
        }
        
        vc.reflectionResponse = self.reflectionResponse
        vc.promptContent = self.promptContent
        vc.authorProfile = MemberProfileService.sharedInstance.currentMemberProfile
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.noteContainerView.addSubview(vc.view)
        self.noteContainerView.layer.cornerRadius = 10
        vc.view.leadingAnchor.constraint(equalTo: self.noteContainerView.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: self.noteContainerView.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: self.noteContainerView.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.noteContainerView.bottomAnchor).isActive = true
        self.didMove(toParent: self)
    }
    
    func configureSharing() {
        if self.reflectionResponse?.shared == true {
            self.shareLinkButton.isHidden = true
            self.shareButton.isHidden = false
        } else {
            self.shareLinkButton.isHidden = false
            self.shareButton.isHidden = true
        }
    }
    
    @IBAction func getShareableLinkTapped(_ sender: Any) {
        ReflectionResponseService.sharedInstance.shareReflection(self.reflectionResponse) { (saved, error) in
            if let error = error {
                self.logger.error("Failed to share reflection response", error)
            }
            if let shared = saved {
                Analytics.logEvent("generate_note_share_link", parameters: ["prompt_id": self.promptContent.promptId ?? ""])
                self.reflectionResponse = shared
            }
            
            self.configureSharing()
            self.shareTapped(sender)
        }
    }
    @IBAction func shareTapped(_ sender: Any) {
        SharingService.shared.shareNote(response: self.reflectionResponse, promptContent: self.promptContent, target: self)
    }
}
