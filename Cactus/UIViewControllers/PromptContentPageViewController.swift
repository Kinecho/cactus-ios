//
//  PromptContentPageViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseFirestore

protocol PromptContentPageViewControllerDelegate: class {
    func didDismissPrompt(promptContent: PromptContent)
}

class PromptContentPageViewController: UIPageViewController {
    
    var promptContent: PromptContent!
    var activeIndex: Int = 0
    var pageControl: UIPageControl?
    var reflectionResponse: ReflectionResponse? {
        didSet {
            self.updateScreenData()
            self.updateCelebrate()
        }
    }
    var closeButton: UIButton?
    var sharePromptButton: UIButton?
    var tapNavigationEnabled = true
    var logger = Logger(fileName: "PromptContentPageViewController")
    var celebrateVc: CelebrateViewController?
    var appSettings: AppSettings?

    var member: CactusMember? {
        didSet {
            self.updateScreenData()
        }
    }
    
    weak var promptDelegate: PromptContentPageViewControllerDelegate?
    
    fileprivate lazy var screens: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
//        self.member = CactusMemberService.sharedInstance.currentMember
//        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember({ (member, _, _) in
//            self.member = member
//        })
//
//        self.appSettings = AppSettingsService.sharedInstance.currentSettings
//        self.settingsUnsubscriber = AppSettingsService.sharedInstance.observeSettings { (settings, _) in
//            self.appSettings = settings
//            self.celebrateVc?.appSettings = settings
//        }
        
        self.configureScreens()
        self.view.backgroundColor = CactusColor.promptBackground
        
        if self.createReflectionResponseIfNeeded(), let response = self.reflectionResponse {
            self.logger.info("Creating a reflection response since none was provided")
            self.save(response, nextPageOnSuccess: false, addReflectionLog: false) { saved, error in
                if let error = error {
                    self.logger.error("Failed to save placeholder reflection response", error)
                    return
                }
                if let saved = saved {
                    self.logger.info("Created & saved placeholder reflection response successfully")
                    self.reflectionResponse = saved
                    self.configureScreens()
                }
            }
        }
    }
    
    deinit {
//        self.settingsUnsubscriber?.remove()
//        self.memberUnsubscriber?()
    }
    
    var currentIsReflect: Bool {
        let vc = self.viewControllers?.first
        return vc is ReflectContentViewController
    }
    
    /** Create a reflection response if it wasn't present. Return true if it was created
     - Returns: Bool if a new prompt was created
     */
    func createReflectionResponseIfNeeded() -> Bool {
        //set up the reflection response if it didn't exist yet
        if let promptId = self.promptContent.promptId, self.reflectionResponse == nil {
            let question = self.promptContent.getQuestion()
            let element = self.promptContent.cactusElement
            self.reflectionResponse = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: question, element: element, medium: .PROMPT_IOS)
            self.logger.info("A reflection respons ewas needed - Created a response.")
            return true
        } else if self.promptContent.promptId == nil {
            self.logger.info("Unable to create a reflection response - NO prompt ID was present")
            return false
        }
        self.logger.info("No need to create a reflection response")
        return false
    }
    
    @objc func tapGestureHandler(touch: UITapGestureRecognizer) {
        guard self.tapNavigationEnabled == true else {return}
        let touchPoint = touch.location(in: self.view)
        let leftX = self.view.bounds.maxX * 0.3
        if touchPoint.x <= leftX {
            self.goToPreviousPage()
        } else {
            self.goToNextPage()
        }
    }
    
    func goToNextPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        self.tapNavigationEnabled = false
        setViewControllers([nextViewController], direction: .forward, animated: animated, completion: { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
            self.tapNavigationEnabled = true
        })
    }
    
    func goToPreviousPage(animated: Bool = true) {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        self.tapNavigationEnabled = false
        setViewControllers([previousViewController], direction: .reverse, animated: animated, completion: { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed)
            self.tapNavigationEnabled = true
            
        })
    }
    
    func configureScreens() {
        var screens: [UIViewController] = []
        self.promptContent.content.forEach({ (content) in
            if let screen = self.getContentViewController(content) {                
                screens.append(screen)
            }
        })
        
//        if let lastScreen = screens.last(where: { $0 is PromptContentViewController} ) as? PromptContentViewController {
//            lastScreen.isLastCard = true
//        }
                
        let celebrate = CelebrateViewController.loadFromNib()
        celebrate.reflectionResponse = self.reflectionResponse
        celebrate.promptContent = self.promptContent
        celebrate.delegate = self
        celebrate.appSettings = self.appSettings
        
        self.celebrateVc = celebrate
        
        /// No longer showing celebrate screen at the end of the content
//        screens.append(celebrate)
        self.screens = screens
        
        if let firstVC = self.screens.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        self.configurePageControl()
        self.addCloseButton()
        self.addSharePromptButton()
    }
    
    func updateScreenData() {
        self.screens.forEach { (screenVc) in
            if let promptVc = screenVc as? PromptContentViewController {
                promptVc.member = self.member
                promptVc.reflectionResponse = self.reflectionResponse
            }
        }
    }
    
    func updateCelebrate() {
        guard let celebrate = self.celebrateVc else {
            self.logger.info("No celebrate screen existed. Can't update it.")
            return
        }
        
        celebrate.reflectionResponse = self.reflectionResponse
    }
    
    func getContentViewController(_ content: Content) -> PromptContentViewController? {
        let index = self.promptContent.content.firstIndex(where: {$0 === content})
        let isLast = index == promptContent.content.endIndex - 1
        
        var viewController: PromptContentViewController?
        var backgroundColor: UIColor? = CactusColor.promptBackground
        switch content.contentType {
        case .text:
            let textViewController = TextContentViewController.loadFromNib()
            viewController = textViewController
        case .quote:
            let quoteViewController = QuoteContentViewController.loadFromNib()
            viewController = quoteViewController
        case .photo:
            let photoViewController = PhotoContentViewController.loadFromNib()
            viewController = photoViewController
        case .reflect:
            let reflectionViewController = ReflectContentViewController.loadFromNib()
            reflectionViewController.reflectionResponse = self.reflectionResponse
            viewController = reflectionViewController
            backgroundColor = .white
        case .elements:
            viewController = CactusElementsViewController.loadFromNib()
        case .video:
            viewController = VideoContentViewController.loadFromNib()
        case .invite:
            viewController = InviteContentViewController.loadFromNib()
        default:
            self.logger.warn("PromptContentPageViewController: ContentType not handled: \(content.contentType)")
        }
        
        if let vc = viewController {
            vc.isLastCard = isLast
            vc.content = content
            vc.promptContent = promptContent
            vc.delegate = self
            vc.member = self.member
        }
        
        viewController?.view.backgroundColor = backgroundColor
        return viewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let pageControl = self.pageControl {
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            //            let bottomConstraint = pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            let left = pageControl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20)
            let right = pageControl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20)
            let topConstraint = pageControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
            //            bottomConstraint.isActive = true
            topConstraint.isActive = true
            left.isActive = true
            right.isActive = true
            view.addConstraints([
                topConstraint,
                left,
                right
                //                bottomConstraint
            ])
        }
        
    }
    
    @objc func dismissPrompt() {
        Vibration.light.vibrate()
        self.dismiss(animated: true, completion: {
            //todo: log analytics that prompt was dismissed
            self.promptDelegate?.didDismissPrompt(promptContent: self.promptContent)
        })
        
    }
    
    func addSharePromptButton() {
        if self.sharePromptButton != nil {
            self.sharePromptButton?.removeFromSuperview()
        }
        let buttonWidth: CGFloat = 50
        let yPos = self.view.bounds.minY + self.view.safeAreaInsets.top + 20
        let xPos = self.view.bounds.minX + 40 + self.view.safeAreaInsets.left
        
        let button = UIButton(frame: CGRect(x: xPos, y: yPos, width: 80, height: 80))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(CactusImage.share.getImage(), for: .normal)
        button.tintColor = CactusColor.green
        
        let contentInset: CGFloat = 10
        button.contentEdgeInsets = UIEdgeInsets.init(top: contentInset, left: contentInset, bottom: contentInset, right: contentInset)
        self.view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        
        button.addTarget(self, action: #selector(self.sharePrompt), for: .primaryActionTriggered)
        
        self.sharePromptButton = button
    }
    
    @objc func sharePrompt() {
        SharingService.shared.sharePromptContent(promptContent: self.promptContent, target: self, sender: self.sharePromptButton)
    }
    
    func addCloseButton() {
        if self.closeButton != nil {
            self.closeButton?.removeFromSuperview()
        }
        let buttonWidth: CGFloat = 50
        let yPos = self.view.bounds.minY + self.view.safeAreaInsets.top + 20
        let xPos = self.view.bounds.maxX - 40 - self.view.safeAreaInsets.right
        let button = UIButton(frame: CGRect(x: xPos, y: yPos, width: 80, height: 80))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(CactusImage.close.getImage(), for: .normal)
        button.tintColor = CactusColor.green
        
        let contentInset: CGFloat = 10
        button.contentEdgeInsets = UIEdgeInsets.init(top: contentInset, left: contentInset, bottom: contentInset, right: contentInset)
        self.view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(self.dismissPrompt), for: .primaryActionTriggered)
        
        self.closeButton = button
    }
    
    func configurePageControl() {
        //note: position is dictated by viewDidLayoutSubviews with constraints
        if self.pageControl != nil {
            self.pageControl?.removeFromSuperview()
        }
        //        let yPos = self.view.bounds.maxY - self.view.safeAreaInsets.top - 40
        let yPos = self.view.bounds.minY + self.view.safeAreaInsets.top + 40
        let pageControl =  UIPageControl(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 50))
        pageControl.backgroundColor = .clear
        pageControl.numberOfPages = self.screens.count
        pageControl.currentPage = 0
        pageControl.tintColor = CactusColor.green
        pageControl.pageIndicatorTintColor = CactusColor.progressBackground
        pageControl.currentPageIndicatorTintColor = CactusColor.green
        
        self.pageControl = pageControl
        self.view.addSubview(pageControl)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}

extension PromptContentPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //        handle previous
        guard let viewControllerIndex = self.screens.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard self.screens.count > previousIndex else { return nil }
        
        if let reflectVc = viewController as? ReflectContentViewController {
            self.logger.info("Saving response on go to previous")
            reflectVc.saveResponse(nextPageOnSuccess: false, silent: true) { saved, error in
                if let error = error {
                    self.logger.error("Failed to save reflectionr response when going to the next page", error)
                }
                if let saved = saved {
                    self.reflectionResponse = saved
                }
            }
        }
        
        return self.screens[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //handle next
        guard let viewControllerIndex = self.screens.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < self.screens.count else { return nil }
        guard self.screens.count > nextIndex else { return nil }
        
        if let reflectVc = viewController as? ReflectContentViewController {
            self.logger.info("Saving response on go to next")
            reflectVc.saveResponse(nextPageOnSuccess: false, silent: true) { saved, error in
                if let error = error {
                    self.logger.error("Failed to save reflectionr response when going to the next page", error)
                }
                if let saved = saved {
                    self.reflectionResponse = saved
                }
            }
        }
        
        return self.screens[nextIndex]
        
    }
}

extension PromptContentPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let firstViewController = self.viewControllers?.first,
            let index = self.screens.firstIndex(of: firstViewController) {
            self.pageControl?.currentPage = index
            
            if index == screens.count - 1 {
                CactusAnalytics.shared.promptCompleted(promptContent: self.promptContent)
            }            
        }
    }
}

extension PromptContentPageViewController: PromptContentViewControllerDelegate {
    var viewController: UIViewController {
        return self
    }
    
    func closePrompt() {
        self.dismissPrompt()
    }
    
    func save(_ response: ReflectionResponse, nextPageOnSuccess: Bool=false, addReflectionLog: Bool=true, completion: ((ReflectionResponse?, Any?) -> Void)?=nil) {
//        self.member
        let coreValueIndex = self.promptContent.preferredCoreValueIndex ?? 0
        let memberCoreValue = self.member?.getCoreValue(at: coreValueIndex)
        
        if response.coreValue == nil {
            response.coreValue = memberCoreValue
        }
        
        ReflectionResponseService.sharedInstance.save(response, addReflectionLog: addReflectionLog) { (saved, error) in
            if let error = error {
                self.logger.error("Error saving reflection response", error)
            }
            completion?(saved, error)
            if error == nil, nextPageOnSuccess {
                self.nextScreen()
            }
        }
    }
    
    func nextScreen() {
        self.goToNextPage()
    }
    
    func previousScreen() {
        self.goToPreviousPage()
    }
    
    func handleTapGesture(touch: UITapGestureRecognizer) {
        self.tapGestureHandler(touch: touch)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        guard self.tapNavigationEnabled, !self.currentIsReflect else {
            super.pressesEnded(presses, with: event)
            return
        }
        
        switch key.keyCode {
        case .keyboardRightArrow:
                self.nextScreen()
        case .keyboardLeftArrow:
                self.previousScreen()
        default:
            super.pressesEnded(presses, with: event)
        }
    }
}

extension PromptContentPageViewController: CelebrateViewControllerDelegate {
    func goHome() {
        self.dismissPrompt()
    }
}
