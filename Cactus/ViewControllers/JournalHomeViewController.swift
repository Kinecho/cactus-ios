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
    var menuDrawerViewController: NavigationMenuViewController!
    var isMenuExpanded = false
    var memberListener:(() -> Void)?
    let overlayView = UIVisualEffectView()
    var alphaView: UIView!
    let menuContainer = UIView()
    
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
        // Do any additional setup after load
        }
        
        // Do any additional setup after loading the view.
    }
    
    func setupDrawer() {
        self.menuDrawerViewController = NavigationMenuViewController.loadFromNib()
        
        self.menuContainer.frame = CGRect(x: self.view.bounds.maxX, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.menuDrawerViewController.view.frame =  CGRect(x: 0, y: 0, width: self.menuWidth, height: self.view.bounds.height)
        
        self.addChild(self.menuDrawerViewController)
        
        self.menuContainer.addSubview(self.menuDrawerViewController.view)
        self.view.addSubview(menuContainer)
        
        self.menuDrawerViewController.didMove(toParent: self)
        
        self.menuContainer.backgroundColor = self.menuDrawerViewController.view.backgroundColor
        self.menuContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.menuContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.menuDrawerViewController.view.leadingAnchor.constraint(equalTo: self.menuContainer.leadingAnchor).isActive = true
        self.menuDrawerViewController.view.topAnchor.constraint(equalTo: self.menuContainer.safeAreaLayoutGuide.topAnchor).isActive = true
        self.menuDrawerViewController.view.bottomAnchor.constraint(equalTo: self.menuContainer.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.setupAvatarGestures()
    }
    
    func toggleMenu() {
        self.isMenuExpanded = !self.isMenuExpanded
        let bounds = self.view.bounds
        let menuX = isMenuExpanded ? bounds.width - self.menuWidth : self.view.frame.maxX
        
        self.overlayView.isHidden = !isMenuExpanded
        let duration = 0.3
        UIView.animate(withDuration: duration, animations: {
            self.overlayView.effect = self.isMenuExpanded ? UIBlurEffect(style: .dark) : nil
            self.profileImageView.transform = self.isMenuExpanded ? CGAffineTransform.init(scaleX: 0.8, y: 0.8) : CGAffineTransform.identity
        })
        
        UIView.animate(withDuration: isMenuExpanded ? 0.8 : 0.3,
                       delay: 0,
                       usingSpringWithDamping: isMenuExpanded ? 0.7 : 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                self.menuContainer.frame = CGRect(x: menuX, y: 0, width: self.view.bounds.width, height: bounds.height)
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
        self.memberListener?()
    }

    func setupView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
