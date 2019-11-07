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
    var journalFeedViewController: JournalFeedCollectionViewController?
    var emptyStateViewController: JournalHomeEmptyStateViewController?
    var menuDrawerViewController: NavigationMenuViewController!
    var isMenuExpanded = false
    var memberListener:(() -> Void)?
    let overlayView = UIVisualEffectView()
    var alphaView: UIView!
    let menuContainer = UIView()
    let journalFeedDataSource = JournalFeedDataSource()
    
    var blurEffect: UIBlurEffect?
    let menuOpenDuration: TimeInterval = 0.5
    let menuCloseDuration: TimeInterval = 0.25
    let blurEffectDuration: TimeInterval = 0.2
    var menuWidth: CGFloat {
        return self.view.bounds.width * 4/5
    }
    var member: CactusMember? {
        didSet {
            self.updateViewForMember(member: self.member)
        }
    }
    
    var user: Firebase.User? {
        didSet {
            self.updateViewForUser(user: self.user)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.overlayView.backgroundColor = .clear
        self.view.addSubview(overlayView)
        self.overlayView.isHidden = true

        self.setupDrawer()
        
        self.memberListener = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, user) in
            if let error = error {
                print("error observing cactus member", error)
            }
            self.user = user
            self.member = member
        }
        
        if #available(iOS 13.0, *) {
            self.blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        } else {
            // Fallback on earlier versions
            self.blurEffect = UIBlurEffect(style: .dark)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupDrawer() {
        self.menuDrawerViewController = NavigationMenuViewController.loadFromNib()
        self.menuDrawerViewController.delegate = self
        self.menuContainer.frame = CGRect(x: self.view.bounds.maxX, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.menuDrawerViewController.view.frame =  CGRect(x: 0, y: 0, width: self.menuWidth, height: self.view.bounds.height)
        
        self.addChild(self.menuDrawerViewController)
        
        self.menuContainer.addSubview(self.menuDrawerViewController.view)
        self.view.addSubview(menuContainer)
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
        
        UIView.animate(withDuration: isMenuExpanded ? menuOpenDuration : menuCloseDuration,
                       delay: 0,
                       usingSpringWithDamping: isMenuExpanded ? 0.7 : 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                self.menuContainer.frame = CGRect(x: menuX, y: 0, width: self.view.bounds.width, height: bounds.height)
        }, completion: {_ in
            self.overlayView.isHidden = !self.isMenuExpanded
        })
        
        if self.isMenuExpanded {
            self.menuDrawerViewController.finishedOpening()
        } else {
            self.menuDrawerViewController.finishedClosing()
        }
        
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
        self.memberListener?()
    }

    func setupView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.headerContainerView.backgroundColor = .clear
        let blurredView = UIVisualEffectView()
        
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .light)
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
        
    }
    
    func updateViewForUser(user: Firebase.User?) {
        
        if let imageUrl = user?.photoURL {
            ImageService.shared.setFromUrl(self.profileImageView, url: imageUrl)
        } else {
            self.profileImageView.image = CactusImage.cactusAvatarOG.getImage()
        }
        
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.toggleMenu()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.overlayView.frame = self.view.bounds
        self.menuContainer.backgroundColor = self.menuDrawerViewController.view.backgroundColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch SegueID.fromString(segue.identifier) {
        case .embedJournalFeed:
            if let vc = segue.destination as? JournalFeedCollectionViewController {
                self.journalFeedViewController = vc
                vc.dataSource = self.journalFeedDataSource
                vc.dataSource.delegate = self
                
            }
        default:
            break
        }

    }
    
    /**
     */
    func configureHomeView() {
        
    }
    
    func showEmptyState() {
        if self.emptyStateViewController == nil {
            self.emptyStateViewController = AppDelegate.shared.rootViewController.getScreen(ScreenID.journalEmpty) as? JournalHomeEmptyStateViewController
        } else {
//            self.emptyStateViewController?.removeFromParent()
        }
        
        if let feedVc = self.journalFeedViewController {
            feedVc.willMove(toParent: nil)
            feedVc.view.removeFromSuperview()
            feedVc.removeFromParent()
        }
        
        guard let emptyVc = self.emptyStateViewController else {
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
        
//        emptyState.willM
        
//        self.containerView
    }
    
    func showJournalFeed() {
         if self.journalFeedViewController == nil {
            self.journalFeedViewController = JournalFeedCollectionViewController()
        } else {
//            self.emptyStateViewController?.removeFromParent()
        }
        
        if let emptyVc = self.emptyStateViewController {
            emptyVc.willMove(toParent: nil)
            emptyVc.view.removeFromSuperview()
            emptyVc.removeFromParent()
        }
        
        guard let journalVc = self.journalFeedViewController else {
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
    func insert(_ journalEntry: JournalEntry, at: Int?) {
        self.journalFeedViewController?.insert(journalEntry, at: at)
    }
    
    func insertItems(_ indexes: [Int]) {
        self.journalFeedViewController?.insertItems(indexes)
    }
    
    func setMenuMetrics() {
//        self.menuDrawerViewController.streak = self.journalFeedDataSource.currentStreak
//        self.menuDrawerViewController.reflectionCount = self.journalFeedDataSource.totalReflections
//        self.menuDrawerViewController.reflectionDurationMs = self.journalFeedDataSource.totalReflectionDurationMs
    }
    
    func updateEntry(_ journalEntry: JournalEntry, at: Int?) {
        self.journalFeedViewController?.updateEntry(journalEntry, at: at)
        
//        if self.journalFeedDataSource.loadingCompleted {
//            self.setMenuMetrics()
//        }
    }
    
    func dataLoaded() {
        if self.journalFeedDataSource.sentPrompts.isEmpty {
            self.showEmptyState()
        } else {
            self.showJournalFeed()
        }
        
        self.journalFeedViewController?.dataLoaded()
    }
    
    func loadingCompleted() {
        self.setMenuMetrics()
    }
}
