//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation

import UIKit

class MainNavigationService {
    private static var _shared: MainNavigationService?
    
    static var sharedInstance: MainNavigationService {
        guard let shared = MainNavigationService._shared else {
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
        guard MainNavigationService._shared == nil else {
            return
        }
        MainNavigationService._shared = MainNavigationService(rootVc: rootVc)
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
}
