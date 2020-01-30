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
import Cloudinary

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var introTextLabel: UILabel!
    let logger = Logger("TodayViewController")
    var currentContent: PromptContent?
    var cloudinary: CLDCloudinary?
    
    var hasLoaded = false
    
    override func viewDidLoad() {
        if !self.hasLoaded {
            
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            
            let config = CLDConfiguration(cloudName: "cactus-app", secure: true)
            self.cloudinary = CLDCloudinary(configuration: config)
            self.hasLoaded = true
        }
            
        super.viewDidLoad()
//        self.showLoading()
        self.loadToday()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openPromptInApp)))
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
            return
        }
        
        if let appURL = URL(string: "\(CactusConfig.customScheme)://cactus.app/prompts/\(entryId)") {
               extensionContext?.open(appURL, completionHandler: nil)
           }
    }
    
    func loadToday(completed: ((NCUpdateResult) -> Void)?=nil) {
        PromptContentService.sharedInstance.getPromptContent(for: Date(), status: .published) { (content, error) in
            if let error = error {
                self.logger.error("Failed to fetch today's content", error)
                self.showError("Unable to load today's prompt.")
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
            self.questionLabel.text = "There is no content today."
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
