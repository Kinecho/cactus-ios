//
//  EmotionsAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class EmotionsAnimationViewController: GenericCactusElementAnimationViewController {
    @IBOutlet weak var leaf1Container: UIView!
    @IBOutlet weak var leaf1: UIImageViewAligned!
    @IBOutlet weak var pot: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var leaf2Container: UIView!
    @IBOutlet weak var leaf2: UIImageViewAligned!
    @IBOutlet weak var leaf3Container: UIView!
    @IBOutlet weak var leaf3: UIImageViewAligned!
    var totalDuration: TimeInterval = 20
    var animationStarted = false
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.startAnimation()
    }

    override func startAnimations() {
        guard self.animationStarted == false else {
            //animations already running, not restarting
            self.resumeAnimations()
            return
        }
        self.animationStarted = true
        self.animateLeaf1()
        self.animateContainer()
        self.animateLeaf2(delay: 5)
        self.animateLeaf3(delay: 8)
    }
    
    func animateLeaf1(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
        let container = self.leaf1Container!
        let image = self.leaf1!
        let originalFrame = container.frame
        let newFrame = CGRect(x: originalFrame.minX, y: originalFrame.maxY, width: originalFrame.width, height: 10)
        container.frame = newFrame
        image.transform = CGAffineTransform(scaleX: 0.5, y: 1 )
        UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, options: .curveEaseOut, animations: {
            container.frame = originalFrame
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf2(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
        let container = self.leaf2Container!
        let image = self.leaf2!
        let potLeft = self.pot.frame.minX
        let originalFrame = container.frame
        let newFrame = CGRect(x: potLeft, y: originalFrame.maxY, width: originalFrame.width, height: 0)
        container.frame = newFrame
        image.transform = CGAffineTransform(scaleX: 0.5, y: 1 )
        UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
            container.frame = originalFrame
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf3(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
        let container = self.leaf3Container!
        let image = self.leaf3!
        let potRight  = self.pot.frame.maxX
        
        let originalFrame = container.frame
        let originalRight = originalFrame.maxX
        let diff = originalRight - potRight
        let newFrame = CGRect(x: originalFrame.minX - diff, y: originalFrame.maxY, width: originalFrame.width, height: 0)
        container.frame = newFrame
        image.transform = CGAffineTransform(scaleX: 0.5, y: 1 )
        UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
            container.frame = originalFrame
            image.transform = CGAffineTransform.identity
        })
    }

    func animateContainer(delay: TimeInterval=0) {
        self.containerView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        UIView.animate(withDuration: totalDuration - delay, delay: delay, options: .curveLinear, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
    }
}
