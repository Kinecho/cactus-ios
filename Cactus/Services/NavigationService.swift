//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

import UIKit

protocol NavigationServiceDelegate: class {
    func open(url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)
}

class NavigationService {
    private static var _shared: NavigationService?
    weak var delegate: NavigationServiceDelegate?
    
    static var shared: NavigationService {
        guard let shared = NavigationService._shared else {
            fatalError("You must call \"initialize\" before using the MainNavigationService.")
        }
        return shared
    }
    
    func getTopViewController() -> UIViewController {
        var topController: UIViewController = self.rootVc
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    var rootVc: UIViewController!
    
    /**
     Initialize the service. This must be called before any other use of this class
     - Parameters:
        - rootVc: The root view controller of the app. 
     */
    static func initialize(rootVc: UIViewController, delegate: NavigationServiceDelegate?=nil) {
        guard NavigationService._shared == nil else {
            return
        }
        NavigationService._shared = NavigationService(rootVc: rootVc, delegate: delegate)
    }
    
    private init(rootVc: UIViewController, delegate: NavigationServiceDelegate?=nil) {
        self.rootVc = rootVc
        self.delegate = delegate
    }
    
    /**
    Get a view controller by it's ScreenID. This is just a proxy to the `ScreenID.getViewController()` method.
     - Parameters:
        - screen: the ScreenID to instantiate
     - Returns: UIViewController
     */
    func getScreen(_ screen: ScreenID) -> UIViewController {
        return screen.getViewController()
    }
    
    /**
    Presents a view controller on the top of the stack
     - Parameters:
        - vc: The view controller to present
        - animated: Animate the view controller's presentation
        - target: The base view controller that will do the presentation. Defaults to the top-most view controller
        - completion: The completion handler that is called when presentation is completed
    */
    func present(_ vc: UIViewController, animated: Bool=true, on target: UIViewController?=nil, completion: (() -> Void)?=nil) {
        DispatchQueue.main.async {
            let target = target ?? self.getTopViewController()
//            target.resign
            target.present(vc, animated: animated, completion: completion)
        }
    }
    
    func presentWebView(url: URL?, animated: Bool=true, on target: UIViewController?=nil, completion: (() -> Void)?=nil) {
        DispatchQueue.main.async { [weak self] in
            guard let webViewController = ScreenID.WebView.getViewController() as? WebViewController else {
                return
            }
            webViewController.becomeFirstResponder()
            webViewController.url = url
            webViewController.modalPresentationStyle = .overFullScreen
            webViewController.modalTransitionStyle = .coverVertical
            self?.present(webViewController, animated: animated, on: target, completion: completion)
        }
    }
    
    func openUrl(url: URL) {
        self.delegate?.open(url: url, options: [:], completionHandler: nil)
    }
    
    func loadPromptContent(promptContentEntryId: String, link: String?=nil) {
        SessionStore.shared.addAuthAction { _ in
            let vc = LoadablePromptContentViewController.loadFromNib()
            vc.originalLink = link
            vc.promptContentEntryId = promptContentEntryId
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .coverVertical
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func loadSharedReflection(reflectionId: String, link: String?=nil) {
        SessionStore.shared.addAuthAction { _ in
            let vc = LoadableSharedReflectionViewController.loadFromNib()
            vc.originalLink = link
            vc.reflectionId = reflectionId
            self.present(vc, animated: true, completion: nil)
        }
    }
}
