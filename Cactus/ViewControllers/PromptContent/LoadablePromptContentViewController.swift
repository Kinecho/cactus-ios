//
//  LoadablePromptContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/14/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class LoadablePromptContentViewController: UIViewController {

    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var errorDescriptionLabel: UILabel!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var openBrowserButton: SecondaryButton!
    @IBOutlet weak var goHomeButton: PrimaryButton!
    
    var originalLink: String?
    var promptContentEntryId: String?
    var logger = Logger(fileName: "LoadablePromptContentViewController")
    var promptContent: PromptContent?
    var reflectionResponses: [ReflectionResponse]?
    var promptContentVC: PromptContentPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPromptContent()
    }

    func loadPromptContent() {
        guard let entryId = self.promptContentEntryId else {
            self.stopLoading()
            self.showError("No prompt could be found")
            return
        }
        
        self.startLoading()
        PromptContentService.sharedInstance.getByEntryId(id: entryId) { (promptContent, error) in
            if let error = error {
                self.logger.error("Failed to load the prompt for entryId \(entryId)", error)
                self.showError("Unable to load the requested prompt. Please try again later")
                return
            }
            self.promptContent = promptContent
            self.showPrompt()
        }
    }
    
    func showPrompt() {
        guard let promptContent = self.promptContent, let promptId = promptContent.promptId else {
            self.showError("No prompt cound be found.")
            return
        }
        
        ReflectionResponseService.sharedInstance.getForPromptId(promptId: promptId) { (responses, error) in
            if let error = error {
                self.logger.error("Failed to fetch responses. Continuing anyway", error)                
            }
            self.reflectionResponses = responses
            guard let vc = AppDelegate.shared.rootViewController.getScreen(ScreenID.promptContentPageView) as? PromptContentPageViewController else {return}
            vc.promptContent = promptContent
            vc.reflectionResponse = self.reflectionResponses?.first
            self.promptContentVC = vc
            vc.willMove(toParent: self)
            self.addChild(vc)
            self.view.addSubview(vc.view)
            
            vc.didMove(toParent: self)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            vc.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    func startLoading() {
        self.hideError()
        self.loadingStackView.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.loadingStackView.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func hideError() {
        self.errorStackView.isHidden = true
    }
    
    func showError(_ message: String, title: String?=nil) {
        self.logger.error("Holy cow! What a cool test error!", message)
        self.stopLoading()
        self.errorStackView.isHidden = false
        self.errorDescriptionLabel.text = message
        if let title = title {
            self.errorTitleLabel.isHidden = false
            self.errorTitleLabel.text = title
        }
        
        if self.canOpenLink() {
            self.openBrowserButton.isHidden = false
        } else {
            self.openBrowserButton.isHidden = true
        }
    }

    @IBAction func goHomeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func canOpenLink() -> Bool {
        guard let originalLink = self.originalLink, let url = URL(string: originalLink) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    @IBAction func openInBrowserTapped(_ sender: Any) {
        guard let originalLink = self.originalLink, let url = URL(string: originalLink) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
