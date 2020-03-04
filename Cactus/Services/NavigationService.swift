//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

import UIKit

class NavigationService {
    private static var _shared: NavigationService?
    
    static var sharedInstance: NavigationService {
        guard let shared = NavigationService._shared else {
            fatalError("You must call \"initialize\" before using the MainNavigationService.")
        }
        return shared
    }
    
    var topViewController: UIViewController {
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
    static func initialize(rootVc: UIViewController) {
        guard NavigationService._shared == nil else {
            return
        }
        NavigationService._shared = NavigationService(rootVc: rootVc)
    }
    
    private init(rootVc: UIViewController) {
        self.rootVc = rootVc
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
        let target = target ?? self.topViewController
        target.present(vc, animated: animated, completion: completion)
    }
    
    func presentWebView(url: URL?, animated: Bool=true, on target: UIViewController?=nil, completion: (() -> Void)?=nil) {
        guard let webViewController = ScreenID.WebView.getViewController() as? WebViewController else {
            return
        }
        webViewController.url = url
        self.present(webViewController, animated: animated, on: target, completion: completion)
    }
}
