//
//  ExperienceAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class ExperienceAnimationViewController: UIViewController, CactusElementAnimationViewController {
    @IBOutlet weak var pot: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stem1Container: UIView!
    @IBOutlet weak var stem1: UIImageViewAligned!
    @IBOutlet weak var stem2Container: UIView!
    @IBOutlet weak var stem2: UIImageViewAligned!
    @IBOutlet weak var stem3Container: UIView!
    @IBOutlet weak var stem3: UIImageViewAligned!
    @IBOutlet weak var stem4Container: UIView!
    @IBOutlet weak var stem4: UIImageViewAligned!
    
    var totalDuration: TimeInterval = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.startAnimation()
    }

    func startAnimations() {
        let firstEndsAt =  totalDuration/2
        self.animateStem1(delay: 0, finishEarly: firstEndsAt)
        self.animateStem2(delay: 2, finishEarly: 5)
        self.animateStem3(delay: 5)
        self.animateStem4(delay: 12)
        self.animateContainer()
    }
    
    func animateStem1(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
         let container = self.stem1Container!
         let image = self.stem1!
         
         let originalFrame = container.frame
         let newFrame = CGRect(x: originalFrame.minX, y: originalFrame.maxY, width: originalFrame.width, height: 10)
         container.frame = newFrame
         image.transform = CGAffineTransform(scaleX: 0.5, y: 1 )
         UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
             container.frame = originalFrame
             image.transform = CGAffineTransform.identity
         })
    }
    
    func animateStem2(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
        let container = self.stem2Container!
        let originalFrame = container.frame
        let newFrame = CGRect(x: originalFrame.minX - originalFrame.width/2, y: originalFrame.minY, width: originalFrame.width, height: originalFrame.height)
        container.frame = newFrame
        container.transform = CGAffineTransform(scaleX: 0.0, y: 0.0 )
        
        UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
            container.frame = originalFrame
            container.transform = CGAffineTransform.identity
        })
    }
    
    func animateStem3(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
           let container = self.stem3Container!
           let image = self.stem3!
           
           let originalFrame = container.frame
           let newFrame = CGRect(x: originalFrame.minX + 30, y: originalFrame.maxY, width: originalFrame.width, height: 0)
           container.frame = newFrame
           image.transform = CGAffineTransform(scaleX: 0.5, y: 1 )
           UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
               container.frame = originalFrame
               image.transform = CGAffineTransform.identity
           })
       }
    
    func animateStem4(delay: TimeInterval = 0, finishEarly: TimeInterval = 0) {
        let container = self.stem4Container!
        let image = self.stem4!
        
        let originalFrame = container.frame
        let newFrame = CGRect(x: originalFrame.minX - 35, y: originalFrame.maxY, width: originalFrame.width, height: 0)
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
