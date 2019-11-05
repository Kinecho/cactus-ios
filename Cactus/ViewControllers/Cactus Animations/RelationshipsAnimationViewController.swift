//
//  RelationshipsAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

enum GrowDirectionX {
    case left
    case right
    case center
}

class RelationshipsAnimationViewController: UIViewController, CactusElementAnimationViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leaf1: UIImageView!
    @IBOutlet weak var leaf2: UIImageView!
    @IBOutlet weak var leaf3: UIImageView!
    @IBOutlet weak var leaf4: UIImageView!
    @IBOutlet weak var leaf5: UIImageView!
    @IBOutlet weak var leaf6: UIImageView!
    @IBOutlet weak var leaf7: UIImageView!
    @IBOutlet weak var leaf8: UIImageView!
    @IBOutlet weak var leaf9: UIImageView!
    
    var totalDuration: TimeInterval = 20
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.startAnimation()
    }
    
    func startAnimations() {
//        self.animateLeaf1()
        self.animateContainer()
        self.standard(image: leaf1, direction: .center, duration: 12, yOffset: 10)
        self.standard(image: leaf2, direction: .right, delay: 2, duration: 12, xOffset: 20, yOffset: 10)
        
        self.standard(image: leaf3, direction: .right, delay: 4, xOffset: -25, yOffset: 15)
        self.standard(image: leaf4, direction: .left, delay: 4.5, xOffset: 25, yOffset: 15)
        
        self.standard(image: leaf5, direction: .left, delay: 8, yOffset: 10)
        self.standard(image: leaf6, direction: .right, delay: 10, yOffset: 10)
        self.standard(image: leaf7, direction: .right, delay: 12, yOffset: 10)
        self.standard(image: leaf8, direction: .left, delay: 14, yOffset: 10)
        self.standard(image: leaf9, direction: .left, delay: 16, yOffset: 10)
    }
    
    func standard(image: UIImageView, direction: GrowDirectionX, delay: TimeInterval = 0, duration: TimeInterval = 10, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        
        let height = image.frame.height
        let width = image.frame.width
        let scalingFactor: CGFloat = 0.0
        let newY = (height - height * scalingFactor)/2 + yOffset
        var newX = (width - width * scalingFactor)/2 + xOffset
        
        switch direction {
        case .center:
            newX = 0
        case .left:
            break
        case .right:
            newX = -1 * newX
        }
        
        image.transform = CGAffineTransform(translationX: newX, y: newY).scaledBy(x: scalingFactor, y: scalingFactor)
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
    
    func animateContainer(delay: TimeInterval=0) {
       self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
       UIView.animate(withDuration: totalDuration - delay, delay: delay, options: .curveLinear, animations: {
           self.containerView.transform = CGAffineTransform.identity
       })
   }
}
