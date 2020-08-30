//
//  SceneDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseUI
import Branch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let logger = Logger("SceneDelegate")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let scene = (scene as? UIWindowScene) else { return }
        // workaround for SceneDelegate continueUserActivity not getting called on cold start
        if let userActivity = connectionOptions.userActivities.first {
            
            BranchScene.shared().scene(scene, continue: userActivity)
        }
        
        
        // Use a UIHostingController as window root view controller
        let window = UIWindow(windowScene: scene)
        let sessionStore = SessionStore.shared
        sessionStore.start()
        
        let checkoutStore = CheckoutStore.shared
        checkoutStore.start()
        
        let appView = AppMain()
            .environmentObject(checkoutStore)
            .environmentObject(sessionStore)
            
        
        
        let appMain = UIHostingController(rootView: appView)
        appMain.view.backgroundColor = NamedColor.Background.uiColor
        
        NavigationService.initialize(rootVc: appMain, delegate: self)
        window.rootViewController = appMain
        
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        self.logger.info("Scene Continue actvity referrerURL \(userActivity.referrerURL?.absoluteString ?? "no referrer url")")
        self.logger.info("Scene Continue actvity webpageURL \(userActivity.webpageURL?.absoluteString ?? "no referrer url")")
        BranchScene.shared().scene(scene, continue: userActivity)
    }
        
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.logger.info("Open URL Contexts")
        BranchScene.shared().scene(scene, openURLContexts: URLContexts)

        URLContexts.forEach { (context) in
//            urlContext.url.absoluteString
            let url = context.url
            let sourceApplication = context.options.sourceApplication
            logger.info("Handling URL \(url.absoluteString)")
            logger.info("Source App is \(sourceApplication ?? "not set")")
            
            
            let handled = self.handleDeepLink(url: url, sourceApplication: sourceApplication)
            logger.info("Is link handled? \(handled)")
        }
    }

    /// return Bool -  if the link will be handled
    func handleDeepLink(url: URL, sourceApplication: String?) -> Bool {
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            self.logger.debug("Handled by firebase auth ui")
            return true
        }
        // other URL handling goes here.
        self.logger.debug("handling custom link scheme \(url)", functionName: #function, line: #line)
        
//        if Branch.getInstance().application(app, open: url, options: options) {
//            self.logger.info("Branch handled the URL open \(url.absoluteString)", functionName: #function)
//            return true
//        }
        

        if UserService.sharedInstance.handleActivityURL(url) {
            return true
        } else if LinkHandlerUtil.handlePromptContent(url) {
            return true
        } else if LinkHandlerUtil.handleSharedResponse(url) {
            return true
        } else if LinkHandlerUtil.handleSignupUrl(url) {
            return true
        } else if LinkHandlerUtil.handleViewController(url) {
            return true
        }
        
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("app.cactus") == .orderedSame,
            let viewName = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            self.logger.info("handling deep link: \(viewName), \(parameters)")
        }
        return false
    }
    
}


extension SceneDelegate: NavigationServiceDelegate {
    func open(url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: options, completionHandler: completionHandler)
    }
}
