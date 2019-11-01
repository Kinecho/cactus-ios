//
//  AppMainViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseAuth

class AppMainViewController: UIViewController {
    private var current: UIViewController
    
    var hasUser = false
    var authHasLoaded = false
    var member: CactusMember?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.setNeedsStatusBarAppearanceUpdate()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let launchStoryboard = UIStoryboard(name: StoryboardID.LaunchScreen.name, bundle: nil)
        self.current = launchStoryboard.instantiateViewController(withIdentifier: ScreenID.LaunchScreen.name)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        let launchStoryboard = UIStoryboard(name: StoryboardID.LaunchScreen.name, bundle: nil)
        self.current = launchStoryboard.instantiateViewController(withIdentifier: ScreenID.LaunchScreen.name)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
        // Do any additional setup after loading the view.
        print("***** setting up auth*****")
        self.setupAuth()
    }
    
    func setupAuth() {        
        _ = CactusMemberService.sharedInstance.observeCurrentMember { (member, _, _) in
            print("setup auth onData", member?.email ?? "no email")
            
            if member == nil {
                print("found member, is null. showing loign screen.")
                _ = self.showScreen(ScreenID.Login, wrapInNav: true)
                self.hasUser = false
            } else if member?.id != self.member?.id {
                print("Found member, not null. showing journal feed")
                _ = self.showScreen(ScreenID.JournalHome, wrapInNav: true)
                self.initOnboarding()
                self.hasUser = true
            }
            self.authHasLoaded = true
            self.member = member
        }
    }
    
    func getScreen(_ screen: ScreenID, _ storyboardId: StoryboardID=StoryboardID.Main) -> UIViewController {
        let storyboard = storyboardId.getStoryboard()
        return storyboard.instantiateViewController(withIdentifier: screen.name)
    }
   
    func showScreen(_ screenId: ScreenID, wrapInNav: Bool=false, animate: ((_ new: UIViewController, _ completion: (() -> Void)?) -> Void)? = nil) -> UIViewController {
        let screen = getScreen(screenId)
        let vc = showScreen(screen, wrapInNav: wrapInNav)
        return vc
    }
    
    func initOnboarding() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "NotificationOnboarding")
        if hasSeenOnboarding {
            print("has seen onboarding")
            return
        }
        
        NotificationService.sharedInstance.hasPushPermissions { (status) in
            DispatchQueue.main.async {
                guard status == .notDetermined else {
                    return
                }
                
                let alert = UIAlertController(title: "Never miss a reflection", message: "Turn on push notifications so you know when it's time to reflect. ", preferredStyle: .alert)                
                alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: {_ in
                    NotificationService.sharedInstance.requestPushPermissions { _ in
                        print("permissions requested")
                    }
                }))
                alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
                AppDelegate.shared.rootViewController.present(alert, animated: true)
                
                UserDefaults.standard.set(true, forKey: "NotificationOnboarding")
            }
        }
    }
    
    func showScreen(_ screen: UIViewController, wrapInNav: Bool=false) -> UIViewController {
        var new = screen
        if wrapInNav {
            new = UINavigationController(rootViewController: screen)
        }
        
        addChild(new)                    // 2
        new.view.frame = view.bounds                   // 3
        self.view.addSubview(new.view)                      // 4
        new.didMove(toParent: self)      // 5
        current.willMove(toParent: nil)  // 6
        current.view.removeFromSuperview()            // 7
        current.removeFromParent()       // 8
        current = new
        print("showScreen...")
        return new
    }
    
    func pushScreen(_ screenId: ScreenID, animate: Bool=true) {
        let screen = getScreen(screenId)

        if  let nav = self.current as? UINavigationController {
            print("Pushing view controller")
            nav.pushViewController(screen, animated: animate)
        } else {
            print("Presenting view controller")
            self.current.present(screen, animated: animate)
        }
        
//        return new
    }
    
}
