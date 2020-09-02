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
    func closePrompt()
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
    var coreValuesViewController: CoreValuesAssessmentViewController?
    var isLastCard: Bool = false
    
    var reflectionResponse: ReflectionResponse? {
        didSet {
            self.reflectionResponseDidSet(updated: self.reflectionResponse, previous: oldValue)
        }
    }
    
    var member: CactusMember? {
        didSet {
            self.memberDidSet(updated: self.member, previous: oldValue)
        }
    }
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
    
    func configureView(){}
    
    ///No Operation. Sub class can override.
    func memberDidSet(updated: CactusMember?, previous: CactusMember?) {
        self.coreValuesViewController?.member = updated
    }
    
    ///No Operation. Sub Class can override.
    func reflectionResponseDidSet(updated: ReflectionResponse?, previous: ReflectionResponse?) {}
    
    func handleViewTapped(touch: UITapGestureRecognizer) {
        self.logger.info("Handle view tapped called")
        if tapNavigationEnabled {
            self.delegate?.handleTapGesture(touch: touch)
        } else {
            self.logger.debug("Tap Navigation is disabled", functionName: #function)
        }
    }
    
    func getValidContentActionButton() -> ActionButton? {
        guard let actionButton = self.content.actionButton,
            actionButton.action != .unknown,
            let label = actionButton.label,
            !isBlank(label) else {
                return nil
        }
        return actionButton
    }
    
    func hasActionButton() -> Bool {
        return self.getValidContentActionButton() != nil
    }
    
    func getLastCardDoneButton() -> UIButton? {
        if self.isLastCard {
            let btn = createStyledButton(style: .buttonPrimary, label: "Done")
            btn.addTarget(self, action: #selector(self.onDone), for: .primaryActionTriggered)            
            return btn
        }
        return nil
    }
    
    @objc func onDone(_ sender: Any?) {
        self.delegate?.closePrompt()
    }
    
    func createActionButton() -> UIButton? {
        guard let actionButton = self.getValidContentActionButton(),
            let label = actionButton.label else {
            return nil
        }
        
        let linkStyle = actionButton.linkStyle ?? .link
        
        let button = createStyledButton(style: linkStyle, label: label)
        button.addTarget(self, action: #selector(self.actionButtonTapped(sender:)), for: .primaryActionTriggered)

        return button
    }
    
    @objc func actionButtonTapped(sender: UIButton) {
        guard let action = self.content.actionButton?.action else {
            return
        }
        
        switch action {
        case .showPricing:
            let vc = ScreenID.Pricing.getViewController()
            vc.modalPresentationStyle = .overCurrentContext
            NavigationService.shared.present(vc)
        case .next:
            self.delegate?.nextScreen()
        case .previous:
            self.delegate?.previousScreen()
        case .complete:
            self.delegate?.closePrompt()
        case .coreValues:
            guard let vc = ScreenID.CoreValuesAssessment.getViewController() as? CoreValuesAssessmentViewController else {
                return
            }
            vc.showTopNavbar = true
            vc.member = self.member
            vc.modalPresentationStyle = .overCurrentContext
            self.coreValuesViewController = vc
            NavigationService.shared.present(vc)
        default:
            //no action
            logger.info("No action handler for action type \(action)")
        }
    }
    
    func createStyledButton(style: LinkStyle, label: String) -> UIButton {
        var button: UIButton
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
        return button
    }
    
    func getValidContentLink() -> ContentLink? {
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
        return link
    }
    
    func hasValidContentLink() -> Bool {
        return self.getValidContentLink() != nil
    }
    
    func createContentLink() -> UIButton? {
        guard let link = getValidContentLink(),
            let label = link.linkLabel else {
            return nil
        }
        let style: LinkStyle = link.linkStyle ?? .link
        let button = createStyledButton(style: style, label: label)
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
        NavigationService.shared.presentWebView(url: components?.url, on: self)
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
        NavigationService.shared.presentWebView(url: URL)
//        self.delegate?.viewController.present(vc, animated: true, completion: nil)
        
        return false
    }
}
