//
//  ShadowView.swift
//  Cactus
//
//  Created by Neil Poulin on 11/11/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class ShadowView: UIView {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            self.layer.cornerRadius
        }
    }
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           self.sharedInit()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           self.sharedInit()
       }
       
       override func prepareForInterfaceBuilder() {
           self.sharedInit()
       }
    
    func sharedInit() {
        self.addShadows()
    }
    
    override func layoutSubviews() {
        self.addShadows()
    }
    
//    func addShadows() {
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 10.0)
//        self.layer.shadowRadius = 12.0
//        self.layer.shadowOpacity = 0.15
//        self.layer.masksToBounds = false
//
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
//    }
}
