//
//  AppMainViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseAuth
//import FirebaseFirestore
class AppMainViewController: UIViewController {
    var current: UIViewController
    let logger = Logger(fileName: "AppMainViewController")
    var hasUser = false
    var authHasLoaded = false
    var member: CactusMember?
    var memberUnsubscriber: Unsubscriber?
    
    var currentStatusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return self.currentStatusBarStyle
        } else {
            // Fallback on earlier versions
            return .default
        }
    }

    func setStatusBarStyle(_ updatedStyle: UIStatusBarStyle) {
        self.currentStatusBarStyle = updatedStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        logger.info("***** setting up auth*****")
        self.setupAuth()
    }
    
    func setupAuth() {        
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember { (member, _, _) in
            self.logger.info("setup auth onData \(member?.email ?? "no email")" )
            
            if member == nil {
                self.logger.info("found member is null. showing loign screen.")
                _ = self.showScreen(ScreenID.Login, wrapInNav: true)
                self.hasUser = false
            } else if let member = member, member.id != self.member?.id {
                self.logger.info("Found member, not null. showing journal home page")
                self.showJournalHome(member: member, wrapInNav: true)
                self.hasUser = true
            }
            self.authHasLoaded = true
            self.member = member
        }
    }
    
    func getJournalFeedViewController() -> JournalFeedCollectionViewController {
        guard let vc = self.getScreen(ScreenID.JournalFeed) as? JournalFeedCollectionViewController else {
            self.logger.error("Unable to get JournalFeedCollectionViewController from storyboard")
            fatalError("Unable to get journal feed view controller")
        }
        return vc
    }
    
    func showJournalHome(member: CactusMember, wrapInNav: Bool) {
        self.logger.info("Showing Journal Home screen for member email \(member.email ?? "none set")")
        guard let vc = self.getScreen(ScreenID.JournalHome) as? JournalHomeViewController else {
            return
        }
        vc.member = member
        _ = showScreen(vc, wrapInNav: true)        
    }
    
    func getScreen(_ screen: ScreenID) -> UIViewController {
        let storyboard = screen.storyboardID.getStoryboard()
        return storyboard.instantiateViewController(withIdentifier: screen.name)
    }
   
    func showScreen(_ screenId: ScreenID, wrapInNav: Bool=false, animate: ((_ new: UIViewController, _ completion: (() -> Void)?) -> Void)? = nil) -> UIViewController {
        let screen = getScreen(screenId)
        let vc = showScreen(screen, wrapInNav: wrapInNav)
        return vc
    }
    
    func loadPromptContent(promptContentEntryId: String, link: String?=nil) {
//        let link = "https://cactus-app-stage.web.app/prompts/IAOrt4jq7sXilcpyprdG"
        
        let vc = LoadablePromptContentViewController.loadFromNib()
        vc.originalLink = link
        vc.promptContentEntryId = promptContentEntryId
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadSharedReflection(reflectionId: String, link: String?=nil) {
        let vc = LoadableSharedReflectionViewController.loadFromNib()
        vc.originalLink = link
        vc.reflectionId = reflectionId
//        vc.modalPresentationStyle = .overFullScreen
//        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func sendLoginEvent(_ loginEvent: LoginEvent) {
        DispatchQueue.global(qos: .background).async {
            var loginEvent = loginEvent
            loginEvent.signupQueryParams = StorageService.sharedInstance.getLocalSignupQueryParams()
            
            ApiService.sharedInstance.sendLoginEvent(loginEvent, completed: { error in
                if let error = error {
                    self.logger.error("Failed to send login event", error)
                    return
                }
                self.logger.info("login event completed")
            })
        }
    }
    
    func showScreen(_ screen: UIViewController, wrapInNav: Bool=false) -> UIViewController {
        var newVc = screen
        if wrapInNav {
            newVc = UINavigationController(rootViewController: screen)
        }
        
        addChild(newVc)
        newVc.view.frame = view.bounds
        self.view.addSubview(newVc.view)
        newVc.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = newVc
        self.logger.info("showScreen...", functionName: #function)
        return newVc
    }
    
    func pushScreen(_ screenId: ScreenID, animate: Bool=true) {
        let screen = getScreen(screenId)

        if  let nav = self.current as? UINavigationController {
            self.logger.info("Pushing view controller")
            nav.pushViewController(screen, animated: animate)
        } else {
            self.logger.info("Presenting view controller")
            self.current.present(screen, animated: animate)
        }
    }
    
}
