//
//  JournalHomeViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/23/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Firebase

class JournalHomeViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    var menuWidthConstraint: NSLayoutConstraint?
    var journalFeedViewController: JournalFeedCollectionViewController?
    var emptyStateViewController: JournalHomeEmptyStateViewController?
    var menuDrawerViewController: NavigationMenuViewController!
    var isMenuExpanded = false
//    var memberListener:(() -> Void)?
    let overlayView = UIVisualEffectView()
    var alphaView: UIView!
    let menuContainer = UIView()
    var journalFeedDataSource: JournalFeedDataSource!
    var currentViewController: UIViewController?
    var blurEffect: UIBlurEffect?
    let menuOpenDuration: TimeInterval = 0.5
    let menuCloseDuration: TimeInterval = 0.25
    let blurEffectDuration: TimeInterval = 0.2
    let logger = Logger(fileName: "JournalHomeViewController")
    var menuWidth: CGFloat {
        let bounds = self.view.bounds
        let width = getMenuWidth(bounds.size)
        return width        
    }
    var member: CactusMember! {
        didSet {
            self.updateViewForMember(member: self.member)
            if let dataSource = self.journalFeedDataSource {
                dataSource.currentMember = member
            }
        }
    }
    
    var user: Firebase.User? {
        didSet {
            self.updateViewForUser(user: self.user)
        }
    }
    
    func getMenuWidth(_ size: CGSize) -> CGFloat {
        return min(400, size.width * 4/5)
    }
    
    var appSettings: AppSettings? {
        didSet {
            if let dataSource = self.journalFeedDataSource {
                dataSource.appSettings = self.appSettings
            }
        }
    }
//    var appSettingsUnsubscriber: ListenerRegistration?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let menuWidth = getMenuWidth(size)
        if isMenuExpanded {
            self.menuContainer.frame = CGRect(x: size.width - menuWidth, y: 0, width: menuWidth, height: size.height)
        } else {
            self.menuContainer.frame = CGRect(x: size.width, y: 0, width: size.width, height: size.height)
        }
        self.menuWidthConstraint?.constant = menuWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            AppMainViewController.shared.setStatusBarStyle(.default)
        }
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.logger.info("Creating journal feed data source with member \(self.member.email ?? "none")", functionName: #function)
        self.appSettings = AppSettingsService.sharedInstance.currentSettings
        self.journalFeedDataSource = JournalFeedDataSource(member: self.member, appSettings: self.appSettings)
        self.journalFeedDataSource.delegate = self
        
        self.setupView()
        
        self.overlayView.backgroundColor = .clear
        self.view.addSubview(overlayView)
        self.overlayView.isHidden = true

        self.setupDrawer()
        
//        self.appSettingsUnsubscriber = AppSettingsService.sharedInstance.observeSettings({ (settings, error) in
//            if error != nil {
//                self.logger.error("Failed to get app settings", error)
//                return
//            }
//            self.appSettings = settings
//            self.journalFeedDataSource.appSettings = settings
//        })
        
//        self.memberListener = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, user) in
//            if let error = error {
//                self.logger.error("error observing cactus member", error)
//            }
//            self.user = user
//            self.member = member
//            self.journalFeedDataSource.currentMember = member
//        }
        
        if #available(iOS 13.0, *) {
            self.blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        } else {
            // Fallback on earlier versions
            self.blurEffect = UIBlurEffect(style: .dark)
        }
        
        self.journalFeedDataSource.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.logger.info("View Will Appear")
        self.navigationController?.setNavigationBarHidden(true, animated: false)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.logger.info("View Did Appear")
//        self.presentPermissionsOnboardingIfNeeded()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func presentPermissionsOnboardingIfNeeded() {
        guard self.journalFeedDataSource.count > 0 else {
            self.logger.info("The data source is empty, not attempting to show onboarding", functionName: #function)
            return
        }
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKey.notificationOnboarding)
        if hasSeenOnboarding {
            logger.info("User has seen onboarding via UserDefeaults[\"NotificationOnboarding\"]", functionName: #function)
            return
        }
        
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                guard status != .authorized else {
                    self.logger.info("user already has push notificatiosn enabled")
                    return
                }
                
                guard let vc = ScreenID.notificationOnboarding.getViewController() as? NotificationOnboardingViewController else {
                    return
                }
                
                vc.status = status
                
                self.present(vc, animated: true, completion: {
                    UserDefaults.standard.set(true, forKey: UserDefaultsKey.notificationOnboarding)
                })
            }
        }
    }
    
    func setupDrawer() {
        self.menuDrawerViewController = NavigationMenuViewController.loadFromNib()
        self.menuDrawerViewController.delegate = self
        self.menuDrawerViewController.view.frame =  CGRect(x: 0, y: 0, width: self.menuWidth, height: self.view.bounds.height)
        self.menuContainer.frame = CGRect(x: self.view.bounds.maxX, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.menuDrawerViewController.modalPresentationCapturesStatusBarAppearance = true
        self.addChild(self.menuDrawerViewController)
        
        self.menuContainer.addSubview(self.menuDrawerViewController.view)
        self.view.addSubview(menuContainer)
        
        self.menuDrawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.menuDrawerViewController.view.leadingAnchor.constraint(equalTo: menuContainer.leadingAnchor).isActive = true
        self.menuDrawerViewController.view.topAnchor.constraint(equalTo: menuContainer.topAnchor).isActive = true
        self.menuDrawerViewController.view.bottomAnchor.constraint(equalTo: menuContainer.bottomAnchor).isActive = true
        
        self.menuWidthConstraint = self.menuDrawerViewController.view.widthAnchor.constraint(equalToConstant: self.menuWidth)
        self.menuWidthConstraint?.isActive = true
        self.menuDrawerViewController.didMove(toParent: self)
        
        self.menuContainer.backgroundColor = self.menuDrawerViewController.view.backgroundColor
        
        //Note: Don't need to add constraints because we're not using autolayout here.
        
        self.setupAvatarGestures()
    }
    
    func toggleMenu() {
        self.isMenuExpanded.toggle()
        self.animateMenu()
    }
    
    func animateMenu() {
        let bounds = self.view.bounds
        let menuX = isMenuExpanded ? bounds.width - self.menuWidth : self.view.frame.maxX
        
        self.overlayView.isHidden = false
        UIView.animate(withDuration: blurEffectDuration, animations: {
            if let blurEffect = self.blurEffect {
                self.overlayView.effect = self.isMenuExpanded ? blurEffect : nil
            } else {
                self.overlayView.alpha = self.isMenuExpanded ? 0.5 : 0
                self.overlayView.backgroundColor = .black
            }
            
            self.profileImageView.transform = self.isMenuExpanded ? CGAffineTransform.init(scaleX: 0.8, y: 0.8) : CGAffineTransform.identity
        })
        if self.isMenuExpanded {
            self.menuDrawerViewController.finishedOpening()
        }
        UIView.animate(withDuration: isMenuExpanded ? menuOpenDuration : menuCloseDuration,
                       delay: 0,
                       usingSpringWithDamping: isMenuExpanded ? 0.7 : 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                self.menuContainer.frame = CGRect(x: menuX, y: 0, width: self.view.bounds.width, height: bounds.height)
        }, completion: {_ in
            self.overlayView.isHidden = !self.isMenuExpanded
            if self.isMenuExpanded {
//                self.menuDrawerViewController.finishedOpening()
            } else {
                self.menuDrawerViewController.finishedClosing()
            }
        })        
    }
    
    func setupAvatarGestures() {
        self.profileImageView.isUserInteractionEnabled = true
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(tapGestureRecognizer:)))
        self.profileImageView.addGestureRecognizer(profileImageTapGestureRecognizer)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeftGesture.direction = .right
        overlayView.addGestureRecognizer(swipeLeftGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlay))
        overlayView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc fileprivate func didSwipeLeft() {
        toggleMenu()
    }

    @objc fileprivate func didTapOverlay() {
        toggleMenu()
    }

    deinit {
//        self.memberListener?()
//        self.appSettingsUnsubscriber?.remove()
    }

    func setupView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.headerContainerView.backgroundColor = .clear
        let blurredView = UIVisualEffectView()
        
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .regular)
            blurredView.effect = effect
        } else if #available(iOS 8.0, *) {
            // Fallback on earlier versions
            let effect = UIBlurEffect(style: .light)
            blurredView.effect = effect
        } else {
            blurredView.alpha = 1
            blurredView.backgroundColor = .white
        }
        blurredView.frame = self.headerContainerView.bounds
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        self.headerContainerView.insertSubview(blurredView, at: 0)
        blurredView.topAnchor.constraint(equalTo: self.headerContainerView.topAnchor).isActive = true
        blurredView.bottomAnchor.constraint(equalTo: self.headerContainerView.bottomAnchor).isActive = true
        blurredView.leadingAnchor.constraint(equalTo: self.headerContainerView.leadingAnchor).isActive = true
        blurredView.trailingAnchor.constraint(equalTo: self.headerContainerView.trailingAnchor).isActive = true
    }
    
    func updateViewForMember(member: CactusMember?) {
//        self.journalFeedDataSource?.curr
        guard self.isViewLoaded else {
            return
        }
        self.logger.info("Update view for member", functionName: #function)
        if member?.subscription?.isInOptInTrial == true {
            self.showTrialBanner()
        } else {
            self.hideTrialBanner()
        }
    }
    
    func updateViewForUser(user: Firebase.User?) {
        guard self.isViewLoaded else {
            return
        }
        self.logger.info("Updating view for user")
        if let imageUrl = user?.photoURL {
            ImageService.shared.setFromUrl(self.profileImageView, url: imageUrl)
        } else {
            self.profileImageView.image = CactusImage.avatar3.getImage()
        }
    }
    
    func hideTrialBanner() {
        self.logger.debug("hiding trial banner")
    }
    
    func showTrialBanner() {
        let daysLeft = self.member.subscription?.trialDaysLeft
        self.logger.debug("showing trial banner with \(daysLeft ?? 0) days left")
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.toggleMenu()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.overlayView.frame = self.view.bounds
        self.menuContainer.backgroundColor = self.menuDrawerViewController.view.backgroundColor
    }

    func configureHomeView() {
        
    }
    
    func showEmptyState() {
        self.logger.info("Showing empty state")
        if self.emptyStateViewController == nil {
            self.emptyStateViewController = ScreenID.journalEmpty.getViewController() as? JournalHomeEmptyStateViewController
        } else {
//            self.emptyStateViewController?.removeFromParent()
        }
        
        if self.currentViewController is JournalHomeEmptyStateViewController {
            self.logger.info("Already showing empty state, returning", functionName: #function)
            return
        }
        
        if let feedVc = self.journalFeedViewController {
            feedVc.willMove(toParent: nil)
            feedVc.view.removeFromSuperview()
            feedVc.removeFromParent()
        }
        
        guard let emptyVc = self.emptyStateViewController else {
            self.logger.warn("No empty state controller was found", functionName: #function)
            return
        }
        
        emptyVc.willMove(toParent: self)
        self.addChild(emptyVc)
        
        self.containerView.addSubview(emptyVc.view)
        emptyVc.view.translatesAutoresizingMaskIntoConstraints = false
        emptyVc.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        emptyVc.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        emptyVc.view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        emptyVc.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        
        emptyVc.didMove(toParent: self)
        self.currentViewController = emptyStateViewController
    }
    
    func showJournalFeed() {
        self.logger.info("showing journal feed")
        if self.currentViewController is JournalFeedCollectionViewController {
            self.logger.info("Already showing journal feed, returning")
            return
        }
        
         if self.journalFeedViewController == nil {
            self.logger.info("JournalFeedController was nil, creating it now")
            self.journalFeedViewController = AppMainViewController.shared.getJournalFeedViewController()
            self.journalFeedViewController?.promptContentDelegate = self
        } else {
            self.logger.info("JournalFeedController already exists, setting it up")
        }
        
        if let emptyVc = self.emptyStateViewController {
            self.logger.info("Empty state existed, removing it now")
            emptyVc.willMove(toParent: nil)
            emptyVc.view.removeFromSuperview()
            emptyVc.removeFromParent()
        }
        
        guard let journalVc = self.journalFeedViewController else {
            self.logger.warn("No journal feed was found, unable to continue setting it up.")
            return
        }
        
        journalVc.dataSource = self.journalFeedDataSource
        journalVc.dataSource.delegate = self
        
        journalVc.willMove(toParent: self)
        self.addChild(journalVc)
        
        self.containerView.addSubview(journalVc.view)
        journalVc.view.translatesAutoresizingMaskIntoConstraints = false
        journalVc.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        journalVc.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        journalVc.view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        journalVc.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        
        self.currentViewController = journalVc
        journalVc.didMove(toParent: self)
    }
}

extension JournalHomeViewController: NavigationMenuViewControllerDelegate {
    func closeMenu() {
        self.isMenuExpanded = false
        self.animateMenu()
    }
    
    func openMenu() {
        self.isMenuExpanded = true
        self.animateMenu()
    }
}

extension JournalHomeViewController: JournalFeedDataSourceDelegate {
    func batchUpdate(addedIndexes: [Int], removedIndexes: [Int]) {
        self.journalFeedViewController?.batchUpdate(addedIndexes: addedIndexes, removedIndexes: removedIndexes)
    }
    
    func removeItems(_ indexes: [Int]) {
        self.journalFeedViewController?.removeItems(indexes)
    }
    
    func insert(_ journalEntry: JournalEntry, at: Int?) {
        self.journalFeedViewController?.insert(journalEntry, at: at)
    }
    
    func insertItems(_ indexes: [Int]) {
        self.journalFeedViewController?.insertItems(indexes)
    }

    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
        self.journalFeedViewController?.updateEntry(journalEntry, at: at)
    }
    
    func dataLoaded() {
        self.logger.info("Data Loaded called. Refreshing collectionView")
        self.journalFeedViewController?.dataLoaded()
    }
    
    func handleEmptyState(hasResults: Bool) {
        self.logger.info("Handle empty state called: hasResults = \(hasResults)")
        if hasResults {
            self.showJournalFeed()
            self.presentPermissionsOnboardingIfNeeded()
        } else {
           self.showEmptyState()
        }
    }
}

extension JournalHomeViewController: PromptContentPageViewControllerDelegate {
    
    func didDismissPrompt(promptContent: PromptContent) {
        guard promptContent.entryId == self.appSettings?.firstPromptContentEntryId,
            !self.member.tier.isPaidTier,
            let pricingVc = ScreenID.Pricing.getViewController() as? PricingViewController else {
                self.presentPermissionsOnboardingIfNeeded()
                return
        }
    
        NavigationService.shared.present(pricingVc, on: self.presentingViewController)
    }
}
