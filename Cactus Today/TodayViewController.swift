//
//  TodayViewController.swift
//  Cactus Today
//
//  Created by Neil Poulin on 1/18/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase
import FirebaseAuth
import Cloudinary

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introTextLabel: UILabel!
    let logger = Logger("TodayViewController")
    var currentContent: PromptContent?
    var cloudinary: CLDCloudinary?
    var member: CactusMember?
    var hasLoaded = false
    var memberLoaded = false
    var memberUnsubscriber: Unsubscriber?
    override func viewDidLoad() {
        if !self.hasLoaded {
            
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
                do {
                    try Auth.auth().useUserAccessGroup(CactusConfig.sharedKeychainGroup)
                } catch let error as NSError {
                  print("Error changing user access group: %@", error)
                }

            }
            
            let config = CLDConfiguration(cloudName: "cactus-app", secure: true)
            self.cloudinary = CLDCloudinary(configuration: config)
            self.hasLoaded = true
        }
        
        super.viewDidLoad()
        
        if memberUnsubscriber == nil {
            self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, error, user) in
                if let error = error {
                    self.logger.error("Failed to load member", error)
                }
                
                if let user = user {
                    self.logger.info("Fetched user from member service: " + user.uid)
                }
                self.member = member
                self.memberLoaded = true
                self.loadToday()
            })
        }
        
        self.showLoading()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openPromptInApp)))
    }
       
    deinit {
        self.memberUnsubscriber?()
    }
    
    ///We can show/hide more content based on this setting
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
//        if activeDisplayMode == .expanded {
//            self.introTextLabel.isHidden = false
//        } else {
//            self.introTextLabel.isHidden = true
//        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.loadToday(completed: {result in
            completionHandler(result)
        })
    }
    
    @objc func openPromptInApp() {
        guard let content = self.currentContent, let entryId = content.entryId else {
            if self.member?.subscription?.tier.isPaidTier != true{
                if let appURL = ScreenID.Pricing.getURL() {
                    extensionContext?.open(appURL, completionHandler: nil)
                }
            }
            
            return
        }
                        
        if let appURL = URL(string: "\(CactusConfig.customScheme)://cactus.app/prompts/\(entryId)") {
           extensionContext?.open(appURL, completionHandler: nil)
       }
    }
    
    func showNeedsLogin() {
        guard self.memberLoaded else {
            self.questionLabel.text = "Loading..."
            return
        }
        
        self.questionLabel.text = "Please log in to see today's prompt"
        self.questionLabel.isHidden = false
        self.imageView.isHidden = true
        self.introTextLabel.isHidden = true
    }
    
    func loadToday(completed: ((NCUpdateResult) -> Void)?=nil) {
        guard let member = self.member else {
            self.showNeedsLogin()
            return
        }
        
        
        PromptContentService.sharedInstance.getPromptContent(for: Date(), status: .published, member: member) { (content, error) in
            if let error = error {
                self.logger.error("Failed to fetch today's content", error)
                if member.subscription?.tier.isPaidTier == true {
                    self.showError("Unable to load today's prompt. Please try again later.")
                } else {
                    self.showError("There is no prompt for today. To get a new prompt every day, please upgrade to Cactus Plus.")
                }
                
                completed?(NCUpdateResult.failed)
                return
            }
            guard let content = content else {
                completed?(NCUpdateResult.noData)
                self.currentContent = nil
                self.configurePromptContent(nil)
                return
            }
            if (self.currentContent?.entryId == content.entryId) {
                completed?(NCUpdateResult.noData)
            }
            self.currentContent = content
            self.configurePromptContent(content)
            completed?(NCUpdateResult.newData)
        }
    }
    
    func showLoading() {
        self.questionLabel.text = "Loading Today's Prompt"
        self.questionLabel.isHidden = false
        self.imageView.isHidden = true
        self.introTextLabel.isHidden = true
    }
    
    func showError(_ message: String) {
        self.questionLabel.text = message
        self.questionLabel.isHidden = true
        self.imageView.isHidden = true
    }
    
    func configurePromptContent(_ promptContent: PromptContent?) {
        guard let content = promptContent else {
            self.imageView.isHidden = true
            if self.member?.subscription?.tier.isPaidTier == true {
                self.questionLabel.text = "There is no prompt today. Please try again later."
            } else {
                self.questionLabel.text = "Get today’s question. Tap to learn more."
            }
            
            self.questionLabel.isHidden = false
            self.introTextLabel.isHidden = true
            return
        }
        
        self.questionLabel.text = content.getQuestion()
        self.introTextLabel.text = content.getIntroText()
        self.introTextLabel.isHidden = isBlank(content.getIntroText())
        self.questionLabel.isHidden = false
        
        let contentImage = content.content.first?.backgroundImage
        if contentImage?.isEmpty == true {
            self.imageView.isHidden = true
        } else {
            self.imageView.isHidden = true
            
            guard let imageUrl = contentImage?.storageUrl, let _url = self.cloudinary?.createUrl().setType(.fetch).setFormat("png").generate(imageUrl) else {
                imageView.isHidden = true
                return
            }
            
            print("Loading image with url \(_url)")
            guard let dataUrl = URL(string: _url) else {
                return
            }
            if let imageData = try? Data(contentsOf: dataUrl), let image = UIImage(data: imageData) {
                self.imageView.setImage(image)
                self.imageView.isHidden = false
            } else {
                self.imageView.isHidden = true
            }            
        }
    }
    
}
