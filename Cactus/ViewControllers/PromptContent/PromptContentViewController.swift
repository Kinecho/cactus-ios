//
//  PromptContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/8/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol PromptContentViewControllerDelegate: class {
    func save(_ response: ReflectionResponse, nextPageOnSuccess: Bool, addReflectionLog: Bool, completion: ((ReflectionResponse?, Any?) -> Void)?)
    func previousScreen()
    func handleTapGesture(touch: UITapGestureRecognizer)
    func nextScreen()
    var viewController: UIViewController {get}
}

// Super Class for various Prompt Content cards
class PromptContentViewController: UIViewController {
    weak var delegate: PromptContentViewControllerDelegate?
    var content: Content!
    var promptContent: PromptContent!
    var tapNavigationEnabled = true
    var selectedTextView: UITextView?
    var appSettings: AppSettings!
    var logger = Logger("PromptContentViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(touch:))))
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    @objc func appMovedToBackground() {
        self.selectedTextView?.endEditing(true)
        self.selectedTextView?.resignFirstResponder()
        self.selectedTextView = nil
    }
    
    @objc func tapGestureHandler(touch: UITapGestureRecognizer) {
        self.handleViewTapped(touch: touch)
    }
    
    func initTextView(_ textView: UITextView) {
        textView.delegate = self
    }
    
    func handleViewTapped(touch: UITapGestureRecognizer) {
        self.logger.info("Handle view tapped called")
        if tapNavigationEnabled {
            self.delegate?.handleTapGesture(touch: touch)
        } else {
            self.logger.debug("Tap Navigation is disabled", functionName: #function)
        }
    }
    
    func createContentLink() -> UIButton? {
        guard let link = self.content.link,
            let href = link.destinationHref,
            let label = link.linkLabel,
            !isBlank(href),
            !isBlank(label)
        else {
            return nil
        }
        guard URL(string: href) != nil else {
            self.logger.warn("content link's href was not a valid URL. Link.destinationHref=\(href)")
            return nil
        }
        var button: UIButton
        let style: LinkStyle = link.linkStyle ?? .link
        switch style {
        case .buttonPrimary:
            button = PrimaryButton()
        case .buttonSecondary:
            button = SecondaryButton()
        case .fancyLink:
            button = FancyLinkButton()
        case .link:
            button = UIButton()
            button.setTitleColor(CactusColor.linkColor, for: .normal)
            let underlinedTitle = NSAttributedString(string: label).withColor(CactusColor.linkColor).withUnderline()
            button.setAttributedTitle(underlinedTitle, for: .normal)
        }
        
        button.setTitle(label, for: .normal)
        button.addTarget(self, action: #selector(self.contentLinkTapped(sender:)), for: .primaryActionTriggered)
        
        return button
    }
    
    @objc func contentLinkTapped(sender: UIButton) {
        guard let href = self.content.link?.destinationHref,
            let url = URL(string: href) else {
                self.logger.warn("content link's href was not a valid URL. Link.destinationHref=\(self.content.link?.destinationHref ?? "undefined")")
            return
        }
        let appendMemberId = self.content.link?.appendMemberId ?? false
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = components?.queryItems ?? []
        if appendMemberId, let memberId = CactusMemberService.sharedInstance.currentMember?.id {
            queryItems.append(URLQueryItem(name: "memberId", value: memberId))
        }
        components?.queryItems = queryItems
        self.logger.info("navigating to url: \(components?.url?.absoluteString ?? "nil")")
        NavigationService.sharedInstance.presentWebView(url: components?.url, on: self)
    }
}

extension PromptContentViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.logger.debug("TextView selection changed")
        self.selectedTextView = textView
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.logger.debug("TextView should interact with url \(URL.absoluteString)")
//        UIApplication.shared.open(URL)
        
//        guard let vc = ScreenID.WebView.getViewController() as? WebViewController else {
//            return false
//        }
//        vc.url = URL
        textView.resignFirstResponder()
        self.resignFirstResponder()
        self.delegate?.viewController.resignFirstResponder()
        NavigationService.sharedInstance.presentWebView(url: URL)
//        self.delegate?.viewController.present(vc, animated: true, completion: nil)
        
        return false
    }
}
