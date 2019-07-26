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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
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
        
        addChild(current)               // 1
        current.view.frame = view.bounds              // 2
        view.addSubview(current.view)                 // 3
        current.didMove(toParent: self) // 4
        // Do any additional setup after loading the view.
        
        self.setupAuth()
    }
    
    
    func setupAuth(){
        Auth.auth().addStateDidChangeListener(){auth, user in
            if user == nil {                
                self.showScreen(ScreenID.Login, wrapInNav: true)
                self.hasUser = false
//            } else if !self.authHasLoaded  {
            } else {
                self.showScreen(ScreenID.Home)
                self.hasUser = true
            }
            self.authHasLoaded = true
        }
    }
    
    func getScreen(_ screen: ScreenID) -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: screen.name)
    }
   
    func showScreen(_ screenId: ScreenID, wrapInNav: Bool=false, animate: ((_ new: UIViewController, _ completion: (() -> Void)?) -> Void)? = nil){
        let screen = getScreen(screenId)
        _ = showScreen(screen, wrapInNav: wrapInNav)
    }
    
    func showScreen(_ screen: UIViewController, wrapInNav: Bool=false) -> UIViewController{
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
    
        return new
    }
    
    
}
