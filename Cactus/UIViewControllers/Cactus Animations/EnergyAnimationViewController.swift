//
//  EnergyAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class EnergyAnimationViewController: GenericCactusElementAnimationViewController {
    @IBOutlet weak var containerView: UIView!
        
    @IBOutlet weak var leaf1: UIImageViewAligned!
    @IBOutlet weak var leaf2: UIImageView!
    @IBOutlet weak var leaf3: UIImageView!
    @IBOutlet weak var leaf4: UIImageView!
    @IBOutlet weak var leaf5: UIImageView!
    @IBOutlet weak var leaf6: UIImageView!
    @IBOutlet weak var leaf7: UIImageView!
    var animationStarted = false
    var totalDuration: TimeInterval = 20
    
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
        super.isAnimating = true
        self.animateContainer()
        self.animateLeaf1(delay: 0)
        self.standard(image: leaf2, delay: 4, scaleX: 0.0, scaleY: 0.0)
        self.animateLeaf3(delay: 8)
        self.animateLeaf4(delay: 12)
        self.animateLeaf5(delay: 14)
        self.animateLeaf6(delay: 17)
        self.animateLeaf7(delay: 19)
    }
    
    func standard(image: UIImageView, delay: TimeInterval = 0, duration: TimeInterval = 10, scaleX: CGFloat = 1.0, scaleY: CGFloat = 1) {
        let height = image.frame.height
        let newY = (height - height * scaleY)/2
        image.transform = CGAffineTransform(translationX: 0, y: newY).scaledBy(x: scaleX, y: scaleY)
     
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf1(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf1!

        let height = image.frame.height
        let scalingFactor: CGFloat = 0.1
        let newY = (height - height * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: 0, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf3(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf3!

        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2
        let newX = (width - width * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: -newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf4(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf4!

        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2
        let newX = (width - width * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: -newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf5(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf5!

        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2
        let newX = (width - width * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf6(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf6!

        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2
        let newX = (width - width * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateLeaf7(delay: TimeInterval = 0, duration: TimeInterval = 10) {
        let image = self.leaf7!

        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2
        let newX = (width - width * scalingFactor)/2
        image.transform = CGAffineTransform(translationX: -newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
        UIView.animate(withDuration: duration, delay: delay, animations: {
            image.transform = CGAffineTransform.identity
        })
    }
    
    func animateContainer(delay: TimeInterval=0) {
        self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: totalDuration - delay, delay: delay, options: .curveLinear, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
    }
}
