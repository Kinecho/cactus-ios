//
//  AppDelegate.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import FirebaseUI
import FirebaseMessaging
import FirebaseCrashlytics
import Sentry
import FacebookCore
import Branch
import FirebaseInAppMessaging
import StoreKit
import FirebaseInstanceID
import Purchases //RevenueCat
import AdSupport //RevenueCat

typealias SentryUser = Sentry.User

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let logger = Logger(fileName: String(describing: AppDelegate.self))
    var fcmToken: String?
    var window: UIWindow?
    var authHasLoaded = false
    var branchInstance: Branch?
    private var currentUser: FirebaseAuth.User?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        do {
            try Auth.auth().useUserAccessGroup(CactusConfig.sharedKeychainGroup)
        } catch {
            self.logger.error("Failed to set up user access group", error)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.info("Loading app will start", functionName: #function)
        self.currentUser = Auth.auth().currentUser
        
        logger.info("EARLY AUTH USER: \(Auth.auth().currentUser?.uid ?? "none")")
        let isFacebokIntent = FacebookCore.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        logger.debug("Is facebook intent: \(isFacebokIntent)", functionName: #function, line: #line)
        
        self.setupBranch(launchOptions: launchOptions)
        
        self.setupRevenueCat()
        SKPaymentQueue.default().add(StoreObserver.sharedInstance)
        
        
        
        Logger.configureLogging(auth: Auth.auth())
        NotificationService.start(application: application)
        
        //Configure Root View controller
        guard let rootVc = ScreenID.AppMain.getViewController() as? AppMainViewController else {
            fatalError("Unable to start main view controller in App Delegate")
        }
        NavigationService.initialize(rootVc: rootVc, delegate: self)
        self.window?.rootViewController = rootVc
        self.window?.makeKeyAndVisible()
        
        CactusMemberService.sharedInstance.instanceIDDelegate = self
        
        return true
    }
    
    func setupRevenueCat() {
        self.logger.info("Setting upu RevenueuCat purchases sdk")
        Purchases.configure(withAPIKey: CactusConfig.revenueCatPublicApiKey, appUserID: self.currentUser?.uid, observerMode: true)
        Purchases.addAttributionData([:], from: .facebook)
        Purchases.debugLogsEnabled = true
        Purchases.shared.finishTransactions = false //set to false because we are finishing the transaction ourself in Cactus code.
    }
    
    func setupBranch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.setBranchKey(CactusConfig.branchPublicKey)
        
        let branchInstance = Branch.getInstance()
        self.branchInstance = branchInstance
        branchInstance.setIdentity(self.currentUser?.uid)
        branchInstance.initSession(launchOptions: launchOptions) { (params, error) in
            defer {
                self.startAuthListener()
            }
            if let error = error {
                self.logger.error("Failed to initialize Branch", error)
                return
            }
            
            if let originalParams = branchInstance.getFirstReferringParams() {
                StorageService.sharedInstance.setBranchParameters(originalParams)
            }
            
            self.logger.info("Branch started")
            self.logger.info("Branch init params: \(String(describing: params as? [String: Any]))")
            StorageService.sharedInstance.setBranchParameters(params)
        }
    }
    
    func startAuthListener() {
        self.logger.debug("Starting auth listener")
        Auth.auth().addStateDidChangeListener {_, user in
            Analytics.logEvent("auth_state_changed", parameters: ["userId": user?.uid ?? "", "previousUserId": self.currentUser?.uid ?? ""])
            if let userId = user?.uid {
                Crashlytics.crashlytics().setUserID(userId)
            }
            
            if let user = user {
                let sentryUser = SentryUser(userId: user.uid)
                sentryUser.email = user.email
                Client.shared?.user = sentryUser
                Purchases.shared.setEmail(user.email)
                Purchases.shared.identify(user.uid) { (info, error) in
                    self.logger.info(String(describing: info))
                    if let error = error {
                        self.logger.error("error", error)
                    }
                    
                    CactusMemberService.sharedInstance.getFCMToken { (token, _) in
                        Purchases.shared.setPushToken(token.data(using: .utf8))
                    }
                }
            } else {
                Purchases.shared.reset()
                
                if let currentUser = self.currentUser {
                    let logoutEvent = Sentry.Event(level: .info)
                    logoutEvent.message = "\(currentUser.email ?? currentUser.uid) has logged out of the app"
                    Client.shared?.send(event: logoutEvent)
                }
                Client.shared?.user = nil
            }
            CactusAnalytics.shared.setUserId(user?.uid)
            self.currentUser = user
            self.authHasLoaded = true
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate:
        // when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationService.sharedInstance.registerForPushIfEnabled(application: application)
        NotificationService.sharedInstance.clearIconBadge()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(StoreObserver.sharedInstance)
    }
    
    //handle handler for result of URL signup flows
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        FacebookCore.ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
       
        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String? else {
            return false
        }
        self.logger.debug("Starting application open url method (line 79)", functionName: #function, line: #line)
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            self.logger.debug("Handled by firebase auth ui")
            return true
        }
        // other URL handling goes here.
        self.logger.debug("handling custom link scheme \(url)", functionName: #function, line: #line)

        if Branch.getInstance().application(app, open: url, options: options) {
            self.logger.info("Branch handled the URL open \(url.absoluteString)", functionName: #function)
            return true
        }
           
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
    
    //handle firebase dynamic links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        self.logger.info("continue User activity webpageurl \(userActivity.webpageURL?.absoluteString ?? "none")", functionName: #function, line: #line)
        
        if let url = userActivity.webpageURL, CactusMemberService.sharedInstance.currentUser == nil {
            let queryParams = url.getQueryParams()
            self.logger.info("Adding signup query params \(String(describing: queryParams))")
            StorageService.sharedInstance.setLocalSignupQueryParams(queryParams)
        }
        if Branch.getInstance().continue(userActivity) {
           return true
       }
        
        if let activityUrl = userActivity.webpageURL {
            if Branch.getInstance().handleDeepLink(activityUrl) {
                self.logger.info("URL was a branch link, letting branch handle it.")
                return true
            } else if UserService.sharedInstance.handleActivityURL(activityUrl) {
                return true
            } else if LinkHandlerUtil.handlePromptContent(activityUrl) {
                return true
            } else if LinkHandlerUtil.handleSharedResponse(activityUrl) {
                return true
            } else if activityUrl.scheme?.starts(with: "http") == true {
                self.logger.warn("url not supported, sending back to the browser: \(activityUrl.absoluteString)")
                application.open(activityUrl)
                return true
            }
        }
        
        return false
    }
}

extension AppDelegate: NavigationServiceDelegate {
    func open(url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: options, completionHandler: completionHandler)
    }    
}

extension AppDelegate: InstanceIDDelegate {
    func getInstanceId(_ completed: @escaping (_ token: String, _ id: String) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                self.logger.error("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                let token = result.token
                let id = result.instanceID
                completed(token, id)
            }
        }
    }
}
