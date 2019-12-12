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
    func startAnimations() {
        fatalError("Subclasses need to implement start animations")
    }
    
    func resumeAnimations() {
        self.view.subviews.forEach { (subview) in
            subview.resumeLayer()
        }
    }
    
    func pauseAnimations() {
        self.view.subviews.forEach { subview in
            subview.pauseLayer()
        }
    }
}
