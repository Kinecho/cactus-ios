//
//  CactusElementAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
//protocol CactusElementAnimationViewController: UIViewController {
//    func startAnimations()
//    func pauseAnimations()
//    func resumeAnimations()
//}

class GenericCactusElementAnimationViewController: UIViewController {
    var isAnimating = false
    
    func startAnimations() {
        fatalError("Subclasses need to implement start animations")
    }
    
    func resumeAnimations() {
        guard isAnimating == false else {return}
        self.isAnimating = true
        self.view.subviews.forEach { (subview) in
            subview.resumeLayer()
        }
    }
    
    func pauseAnimations() {
        guard isAnimating == true else {return}
        self.isAnimating = false
        self.view.subviews.forEach { subview in
            subview.pauseLayer()
        }
    }
}
