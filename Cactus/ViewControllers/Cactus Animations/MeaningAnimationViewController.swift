//
//  MeaningAnimationViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/3/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class MeaningAnimationViewController: GenericCactusElementAnimationViewController {
    @IBOutlet weak var stem1: UIImageView!
    @IBOutlet weak var stem2: UIImageView!
    @IBOutlet weak var pot: UIImageView!
    @IBOutlet weak var stem1Container: UIView!
    @IBOutlet weak var stem2Container: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var animationStarted = false
    let totalDuration: TimeInterval = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pot.layer.cornerRadius = 10
    }
    
    override func startAnimations() {
        guard self.animationStarted == false else {
            //animations already running, not restarting
            self.resumeAnimations()
            return
        }
        self.animationStarted = true
        self.animateStem1(delay: 0, finishEarly: 5)
        self.animateStem2(delay: 10)
        self.animateContainer()
    }
    
    func animateStem1(delay: TimeInterval=0, finishEarly: TimeInterval = 0) {
        let originalFrame = self.stem1Container!.frame
        let noHeightFrame = CGRect(x: originalFrame.minX, y: originalFrame.maxY, width: originalFrame.width, height: 0)
        self.stem1Container.frame = noHeightFrame
        self.stem1.transform = CGAffineTransform(scaleX: 0.5, y: 1)
        UIView.animate(withDuration: totalDuration - delay - finishEarly, delay: delay, animations: {
            self.stem1Container.frame = originalFrame
            self.stem1.transform = CGAffineTransform.identity
        })
    }
    
    func animateStem2(delay: TimeInterval=0) {
        let originalFrame = self.stem2Container.frame
        let noHeightFrame = CGRect(x: originalFrame.minX, y: originalFrame.maxY, width: originalFrame.width, height: 0)
        self.stem2Container.frame = noHeightFrame
        self.stem2.transform = CGAffineTransform(scaleX: 0.5, y: 1)

        UIView.animate(withDuration: totalDuration - delay, delay: delay, animations: {
            self.stem2Container.frame = originalFrame
            self.stem2.transform = CGAffineTransform.identity
        })
    }
    
    func animateContainer(delay: TimeInterval=0) {
        self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: totalDuration - delay, delay: delay, options: .curveLinear, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
    }
}
